local httpServer = require('httpserv')

-- wired up per http://www.microyum.cc/wp-content/uploads/2018/06/2.0-SPI-wiring-1024x1024.jpg

local pins = {
  rs = 2, -- D2, GPIO4
  cs = 8, -- D8, GPIO15
  rst = 4, -- D4, GPIO2
  led = 1, -- D1, GPIO5
}

screen = require('ili9225')(pins)

screen:init()

screen.init = nil

local function httpHandler(req, res)
  if req.url:sub(1, 6) == '/blit?' and req.method == 'POST' then
    function req:ondata(chunk)
      if chunk then
        screen:fill(chunk)
      else
        res:send()
        res:finish()
      end
    end
  elseif req.url:sub(1, 8) == '/window?' and req.method == 'POST' then
    local params = {}
    for k, v in req.url:sub(9):gmatch('([^&]-)=([^&]*)') do
      params[k] = v
    end
    screen:window(
      tonumber(params.x0), tonumber(params.x1),
      tonumber(params.y0), tonumber(params.y1), params.landscape)
    res:send()
    res:finish()
  else
    -- technically, due to the HTTP server implementation ganked here's hacks,
    -- this is going to send "404 Not Found OK", but I'm "OK" with that
    res:send(nil, '404 Not Found')
    res:finish()
  end
end

httpServer.createServer(80, httpHandler)
