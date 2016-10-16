Relay1 = 5
Relay2 = 6
Relay3 = 7
Relay4 = 2

gpio.mode(Relay1, gpio.OUTPUT)
gpio.write(Relay1, gpio.LOW);
gpio.mode(Relay2, gpio.OUTPUT)
gpio.write(Relay2, gpio.LOW);
gpio.mode(Relay3, gpio.OUTPUT)
gpio.write(Relay3, gpio.LOW);
gpio.mode(Relay4, gpio.OUTPUT)
gpio.write(Relay4, gpio.LOW);

RelayStatus1=0
RelayStatus2=0
RelayStatus3=0
RelayStatus4=0

button1ON = "button buttonDisable";
button1OFF = "button buttonOFF";
button2ON = "button buttonDisable";
button2OFF = "button buttonOFF";
button3ON = "button buttonDisable";
button3OFF = "button buttonOFF";
button4ON = "button buttonDisable";
button4OFF = "button buttonOFF";

function WiFi()
wifi.setmode(wifi.STATION)
cfg = {
    ip="192.168.0.88",
    netmask="255.255.255.0",
    gateway="192.168.0.1"
  }
wifi.sta.setip(cfg)
wifi.sta.config("H8","qwQW1234")
wifi.sta.autoconnect(1)
ServerURL = wifi.sta.getip();
print ("Wifi Switch Control Start (OK)\r")
end

function www()
print(ServerURL.."\r")

if srv~=nil then
  srv:close()
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local html_buffer = "";
        local html_buffer1 = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
         local _on,_off = "",""

if(_GET.pin~=nil)then
        if(_GET.pin == "ON1")then
              gpio.write(Relay1, gpio.HIGH);
              RelayStatus1=1
        elseif(_GET.pin == "OFF1")then
              gpio.write(Relay1, gpio.LOW);
              RelayStatus1=0
        elseif(_GET.pin == "ON2")then
              gpio.write(Relay2, gpio.HIGH);
              RelayStatus2=1
        elseif(_GET.pin == "OFF2")then
              gpio.write(Relay2, gpio.LOW);
              RelayStatus2=0
        elseif(_GET.pin == "ON3")then
              gpio.write(Relay3, gpio.HIGH);
              RelayStatus3=1
        elseif(_GET.pin == "OFF3")then
              gpio.write(Relay3, gpio.LOW);
              RelayStatus3=0
        elseif(_GET.pin == "ON4")then
              gpio.write(Relay4, gpio.HIGH);
              RelayStatus4=1
        elseif(_GET.pin == "OFF4")then
              gpio.write(Relay4, gpio.LOW);
              RelayStatus4=0
        end

        if(RelayStatus1 == 0)then
            button1ON = "button buttonDisable";
            button1OFF = "button buttonOFF";
        elseif(RelayStatus1 == 1)then
            button1ON = "button buttonON";
            button1OFF = "button buttonDisable";
        end

        if(RelayStatus2 == 0)then
            button2ON = "button buttonDisable";
            button2OFF = "button buttonOFF";
        elseif(RelayStatus2 == 1)then
            button2ON = "button buttonON";
            button2OFF = "button buttonDisable";
        end

        if(RelayStatus3 == 0)then
            button3ON = "button buttonDisable";
            button3OFF = "button buttonOFF";
        elseif(RelayStatus3 == 1)then
            button3ON = "button buttonON";
            button3OFF = "button buttonDisable";
        end

        if(RelayStatus4 == 0)then
            button4ON = "button buttonDisable";
            button4OFF = "button buttonOFF";
        elseif(RelayStatus4 == 1)then
            button4ON = "button buttonON";
            button4OFF = "button buttonDisable";
        end
  html_buffer = html_buffer.."<html><head><meta http-equiv=\"refresh\" content=\"0;URL='http://"..ServerURL.."/'\" /></head><body></body></html>";
else
  print("heap"..node.heap())
  html_buffer = html_buffer.."<html><head><meta http-equiv=\"Content-Language\" content=\"en-us\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1252\">";
  html_buffer = html_buffer.."<style>.button { border: none; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; border-radius: 8px;}";
  html_buffer = html_buffer..".buttonON {background-color: #4CAF50; cursor: not-allowed;} .buttonOFF {background-color: #f44336; cursor: not-allowed;} .buttonDisable {background-color: #e7e7e7; color: black; opacity: 0.6;}";
  html_buffer = html_buffer.." body {font-family: Arial, Helvetica, sans-serif;} </style></head>";
  html_buffer1 = html_buffer1.."<body>";
  temp, humi=readdht11();
  html_buffer1 = html_buffer1.."<br>Temp : "..temp..", Humidity : "..humi;
  html_buffer1 = html_buffer1.."<br>Heap : "..node.heap();
  html_buffer1 = html_buffer1.."<br>Switch 1 <a href=\"?pin=ON1\"><button class=\""..button1ON.."\"><b>ON</button></b></a> <a href=\"?pin=OFF1\"><button class=\""..button1OFF.."\"><b>OFF</button></b></a>";
  html_buffer1 = html_buffer1.."<br>Switch 2 <a href=\"?pin=ON2\"><button class=\""..button2ON.."\"><b>ON</button></b></a> <a href=\"?pin=OFF2\"><button class=\""..button2OFF.."\"><b>OFF</button></b></a>";
  html_buffer1 = html_buffer1.."<br>Switch 3 <a href=\"?pin=ON3\"><button class=\""..button3ON.."\"><b>ON</button></b></a> <a href=\"?pin=OFF3\"><button class=\""..button3OFF.."\"><b>OFF</button></b></a>";
  html_buffer1 = html_buffer1.."<br>Switch 4 <a href=\"?pin=ON4\"><button class=\""..button4ON.."\"><b>ON</button></b></a> <a href=\"?pin=OFF4\"><button class=\""..button4OFF.."\"><b>OFF</button></b></a>";
  html_buffer1 = html_buffer1.."</body></html>";
end
        client:send("HTTP/1.1 200 OK\nContent-Type: text/html\n\n"..html_buffer..html_buffer1);
        client:close();
        collectgarbage();
    end)
end)
end

function readdht11()
pin = 1
status, temp, humi, temp_dec, humi_dec = dht.read(pin)
if status == dht.OK then
    -- Integer firmware using this example
    print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
          math.floor(temp),
          temp_dec,
          math.floor(humi),
          humi_dec
    ))

    -- Float firmware using this example
    print("DHT Temperature:"..temp..";".."Humidity:"..humi)

elseif status == dht.ERROR_CHECKSUM then
    print( "DHT Checksum error." )
    temp="0"
    humi="0"
elseif status == dht.ERROR_TIMEOUT then
    print( "DHT timed out." )
    temp="0"
    humi="0"
end
return temp, humi
end

function sendTS()
  WRITEKEY="78YLDA62CJ5UXTO5"
  temp, humi=readdht11()
  if (temp == nil) then
  else
      uptime = uptime + 1
      conn = nil
      conn = net.createConnection(net.TCP, 0)
      conn:on("receive", function(conn, payload)success = true print(payload)end)
      conn:on("connection",
      function(conn, payload)
      print("Connected")
      conn:send('GET /update?key='..WRITEKEY..'&field1='..temp..'&field2='..node.heap()..'&field3='..uptime..'&field4='..humi..'HTTP/1.1\r\n\
      Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n')end)
      conn:on("disconnection", function(conn, payload) print('Disconnected') end)
      conn:connect(80,'184.106.153.149')
  end
end

uptime=0
WiFi()
www()
tmr.alarm(1,300000,1,function() sendTS(); end)
