#include "ESP8266WiFi.h"
#include "ESP8266HTTPClient.h"
#include "WiFiClient.h"
#define RELAY1 14
#define RELAY2 12
#define RELAY3 13

#include "DHT.h"
#define DHTPIN 0
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

String app_ver ="Version 11.05.2022";
const char* ssid = "XX";
const char* password = "xxxxxxxx";
unsigned char status_RELAY = 0;
WiFiServer server(80);

// Set your Static IP address Switch 3CH = 190, TEST Esp8266 191
IPAddress local_IP(192, 168, 0, 189);
// Set your Gateway IP address
IPAddress gateway(192, 168, 0, 1);
IPAddress subnet(255, 255, 0, 0);
IPAddress primaryDNS(8, 8, 8, 8);   //optional
IPAddress secondaryDNS(8, 8, 4, 4); //optional

// THE DEFAULT TIMER IS SET TO 10 SECONDS FOR TESTING PURPOSES
// For a final application, check the API call limits per hour/minute to avoid getting blocked/banned
unsigned long lastTime = 0;
// Timer set to 10 minutes (600000)
//unsigned long timerDelay = 600000;
// Set timer to 10 seconds (10000)
unsigned long timerDelay = 300000;

int uptime = 0;

//ThingSpeak
//apikey Switch 3CH
String apikey = "XXXXXXXXXXXX";

//apikey Test ESP8266
//String apikey = "XXXXXXXXXXXX";

String fogstatus;

void setup() {
    Serial.begin(115200);
    pinMode(RELAY1, OUTPUT);
    pinMode(RELAY2, OUTPUT);
    pinMode(RELAY3, OUTPUT);
    digitalWrite(RELAY1, LOW);
    digitalWrite(RELAY2, LOW);
    digitalWrite(RELAY3, LOW);
    fogstatus = "<a href='fog3on'>Fog 3 OFF</a>";
    
    Serial.println();
    
   // Configures static IP address
  if (!WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS)) {
    Serial.println("STA Failed to configure");
  }
    Serial.print("Connecting to ");
    Serial.println(ssid);
    WiFi.begin(ssid, password);
    
    while (WiFi.status() != WL_CONNECTED)
    {
      delay(500);
      Serial.print(".");
    }
    
    Serial.println("");
    Serial.println("WiFi connected");
    server.begin();
    Serial.println("Server started");
    Serial.println(WiFi.localIP());
}

void loop() {

    String h, t;
    String heap,data,command;
       
/////////////////////////////////////////
  // Send an HTTP GET request
  if ((millis() - lastTime) > timerDelay) {
    h = humidity();
    t = temp();
    heap = String(ESP.getFreeHeap(),DEC);
    uptime++;

    if(apikey != "")
    {
      data = "http://api.thingspeak.com/update?api_key=" + apikey + "&field1=" + String(t) + "&field2=" + heap + "&field3=" + String(uptime) + "&field4=" + String(h);
      Serial.println("Send data : " + data);
      
      // Check WiFi connection status
      if(WiFi.status()== WL_CONNECTED){
        WiFiClient client;
        HTTPClient http;
        
        // Your Domain name with URL path or IP address with path
        http.begin(client, data.c_str());
        
        // Send HTTP GET request
        int httpResponseCode = http.GET();
        
        if (httpResponseCode>0) {
          Serial.print("HTTP Response code: ");
          Serial.println(httpResponseCode);
          String payload = http.getString();
          Serial.println(payload);
        }
        else {
          Serial.print("Error code: ");
          Serial.println(httpResponseCode);
        }
        // Free resources
        http.end();
      }
      else {
        Serial.println("WiFi Disconnected");
      }
    }
    
    lastTime = millis();
    
  }
 ////////////////////////////////////////   
  
    WiFiClient client = server.available();
    if (!client) {
        return;
    }
    else
    {            
        Serial.println("new client");
        heap = String(ESP.getFreeHeap(),DEC);
        Serial.println(heap);
        t = temp();
        h = humidity();
        
        while (!client.available())
        {
          delay(1);
        }
        
        String req = client.readStringUntil('\r');
        Serial.println(req);
        client.flush();
        
        if (req.indexOf("/fog1") != -1) {
          digitalWrite(RELAY1, HIGH);
          Serial.print("Fog 1 ON GPIO:");
          Serial.println(RELAY1);
          delay(500);
          digitalWrite(RELAY1, LOW);
          command = "Fog 1 ON ";
        }
        else if (req.indexOf("/fog2") != -1) {
          digitalWrite(RELAY2, HIGH);
          Serial.print("Fog 2 ON GPIO:");
          Serial.println(RELAY2);
          delay(500);
          digitalWrite(RELAY2, LOW);
          command = "Fog 2 ON ";
        }
        else if (req.indexOf("/fog3on") != -1) {
          digitalWrite(RELAY3, HIGH);
          Serial.print("Fog 3 ON GPIO:");
          Serial.println(RELAY3);
          command = "Fog 3 ON ";
          fogstatus ="<a href='/fog3off'>Fog 3 ON</a>";
          delay(500);
        }
        else if (req.indexOf("/fog3off") != -1) {
          digitalWrite(RELAY3, LOW);
          Serial.print("Fog 3 OFF GPIO:");
          Serial.println(RELAY3);
          command = "Fog 3 OFF ";
          fogstatus ="<a href='fog3on'>Fog 3 OFF</a>";
          delay(500);
        }
        
        //Code HTML
        String htmlhead = HTMLhead(app_ver);
        String htmlbottom = HTMLbottom();
        String web = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n";
        web += "\r\n"; web += "\r\n";
        web += htmlhead;
        web += "\r\n<br>Command:" + command;
        web += "\r\n<br>Fog Status:" + String(fogstatus) + "<br>Temp:" + String(t) + "<br>Humidity:" + String(h) + "<br>Heap:" + heap + "<br>uptime: " + String(uptime);
        web += htmlbottom;
        web += "\r\n";
        web += "\r\n"; web += "\r\n";
        client.print(web);       
    }
}
   
    String temp(){
      int x = dht.readTemperature();
        if ( x < 0 || x > 50 ){ 
          return "";
        }else{
          return String(x); }
    }
    
    String humidity(){
      int x = dht.readHumidity();
        if ( x < 1 || x > 100 ){ 
          return "";
        }else{ 
          return String(x); }
    }

    String HTMLhead(String title){
      String w = "<html><head><title>" + String(title) + "</title></head><body>" + String(title) + "<br><br>";
      return w;
    }

    String HTMLbottom(){
      String w = "</body></html>";
      return w;
    }
