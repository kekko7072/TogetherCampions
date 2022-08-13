//NOTE ERROR: if keeps reboting the sim has no credit.

// libraries
#include <MKRGSM.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoLowPower.h>
#include "arduino_secrets.h"


const char PINNUMBER[] = SECRET_PINNUMBER;
const char GPRS_APN[] = SECRET_GPRS_APN;
const char GPRS_LOGIN[] = SECRET_GPRS_LOGIN;
const char GPRS_PASSWORD[] = SECRET_GPRS_PASSWORD;

//GSM
GSMClient client;
GPRS gprs;
GSM gsmAccess;

//DEVICE
char device_name[] = "Traker";
int delay_seconds = 5;
float battery = 0;

//SERVER https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
char server[] = "together-champions.ew.r.appspot.com";
char path[] = "/sendData";
int port = 80;  // port 80 is the default for HTTP

//USER
char device_user[] = "RA207twfQF5LawcErH8j";


void setup() {
  //MODEM.debug();

  //LED
  pinMode(LED_BUILTIN, OUTPUT);


  //Comunication
  Serial.begin(9600);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for native USB port only
  }

  Serial.println("Initialized " + String(device_name));

  //GPRS
  bool connected = false;

  while (!connected) {
    if ((gsmAccess.begin(PINNUMBER) == GSM_READY) && (gprs.attachGPRS(GPRS_APN, GPRS_LOGIN, GPRS_PASSWORD) == GPRS_READY)) {
      connected = true;
      digitalWrite(LED_BUILTIN, HIGH);
      delay(1000);
      digitalWrite(LED_BUILTIN, LOW);
    } else {
      Serial.println("Not connected");
      delay(1000);
    }
  }

  //GPS
  if (!GPS.begin()) {
    Serial.println("Failed to initialize GPS!");
    while (1)
      ;
  }
}

void loop() {

  readBattery();

  sendData();

  /*
 //TODO not printing, but in example works

  if (!client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.available() && !client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
  }*/

  Serial.println("Await " + String(delay_seconds) + " seconds.");
  LowPower.sleep(delay_seconds * 1000);
  /*for (int i = 0; i < delay_seconds; i++) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(1000);
    digitalWrite(LED_BUILTIN, HIGH);
    //Serial.print(".");
  }*/
}

void readBattery() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(ADC_BATTERY);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 4.3V):
  battery = sensorValue * (4.3 / 1023.0);
  Serial.println("Battery voltage: " + String(battery) + " V");

  if (battery < 0.5) {
    ///Stopping the execution to blink and show that battery is low
    Serial.println("RECHARGE: Battery voltage is low");
    PinStatus ledBATTERY = HIGH;
    while (true) {
      digitalWrite(LED_BUILTIN, ledBATTERY);
      delay(100);
      ledBATTERY = ledBATTERY == HIGH ? LOW : HIGH;
    }
  }
}

void sendData() {
  Serial.println();
  Serial.println("..........");
  Serial.println("Sending data: START");
  digitalWrite(LED_BUILTIN, HIGH);

  Serial.println();
  Serial.println("User: " + String(device_user));
  Serial.println();

  //GPS
  Serial.println("Connecting GPS...");
  unsigned long startGPSMillis = millis();
  PinStatus ledGPS = HIGH;
  while (!GPS.available()) {
    digitalWrite(LED_BUILTIN, ledGPS);
    delay(500);
    ledGPS = ledGPS == HIGH ? LOW : HIGH;
  };
  unsigned long endGPSMillis = millis();
  Serial.println("GPS connected in " + String(endGPSMillis - startGPSMillis) + " ms");


  float latitude = GPS.latitude();
  float longitude = GPS.longitude();
  float altitude = GPS.altitude();
  float speed = GPS.speed();
  int satellites = GPS.satellites();


  //SERVER
  Serial.println("Connecting SERVER... ");
  unsigned long startServerMillis = millis();
  if (client.connect(server, port)) {  // if you get a connection, report back via serial:
    unsigned long endServerMillis = millis();
    Serial.println("Server connected in " + String(endServerMillis - startServerMillis) + " ms");


    // Make a HTTP request:
    client.print("GET ");
    client.print(path);
    //Uid
    client.print("?uid=");
    client.print(device_user);
    //Battery
    client.print("&battery=");
    client.print(battery);
    //Lat
    client.print("&latitude=");
    client.print(latitude, 7);
    //Lng
    client.print("&longitude=");
    client.print(longitude, 7);
    //Alt
    client.print("&altitude=");
    client.print(altitude);
    //Speed
    client.print("&speed=");
    client.print(speed);
    //Satelites
    client.print("&satellites=");
    client.print(satellites);
    client.println(" HTTP/1.1");
    client.print("Host: ");
    client.println(server);
    client.println("Connection: close");
    client.println();

  } else {
    Serial.println("connection failed");
  }

  digitalWrite(LED_BUILTIN, LOW);
  Serial.println("Sending data: END");
  Serial.println("..........");
  Serial.println();
}