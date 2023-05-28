/*


BUG IN TOO MUCH MEMORY USED! RFEMOVE ALL THE STRING DEFINITION
COMPILE BUT NOT WORK DUE TO MEMORY USAGE ISSUE
*/


#include <TinyGPS++.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include "configuration.h"
#include "system.h"
#include "mpu.h"
#include "gps.h"
#include "sdcard.h"
#include "UUID.h"
#include <MKRGSM.h>
#include <MQTT.h>


GSMClient net;
GPRS gprs;
GSM gsmAccess;
MQTTClient client;




//SERVICES
long previousMillis = 0;

//GPS
TinyGPSPlus gps;
TinyGPSCustom magneticVariation(gps, "GPRMC", 10);

UUID uuid;

void connectSIMandMQTT() {
  Serial.print("Connecting to cellular network ...");

  bool connected = false;

  // After starting the modem with gsmAccess.begin()
  // attach to the GPRS network with the APN, login and password
  while (!connected) {
    if ((gsmAccess.begin(SIM_PIN) == GSM_READY) && (gprs.attachGPRS(SIM_APN, SIM_LOGIN, SIM_PASSWORD) == GPRS_READY)) {
      connected = true;
      Serial.println("\nconnected!");
    } else {
      Serial.print(".");
      delay(1000);
    }
  }
  client.begin(MQTT_SERVER, MQTT_SERVER_PORT, net);


  Serial.print("\nConnecting to MQTT ...");
  while (!client.connect(DEVICE_SERIAL_NUMBER, MQTT_SERVER_KEY, MQTT_SERVER_SECRET)) {
    Serial.print(".");
    delay(1000);
  }

  Serial.println("\nconnected!");

  //client.subscribe("/timestamp");
}

void setup() {

  //Initialize serial communication
  Serial.begin(9600);

  //Initialize the built-in LED
  pinMode(LED_BUILTIN, OUTPUT);

  //SDCARD
  initializeSDCARD(chip_select);

  //MPU-6050
  setupMPU();

  //GPS
  setupGPS();

  //SIM & MQTT
  connectSIMandMQTT();

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
  client.loop();

  if (!client.connected()) {
    connectSIMandMQTT();
  }

  long currentMillis = millis();

  if (currentMillis - previousMillis >= measurements_milliseconds) {

    //System
    updateSystem(currentMillis, client);

    //GPS
    updateGPSPosition(currentMillis, client, gps);
    updateGPSNavigation(currentMillis, client, gps, magneticVariation);

    //MPU
    updateMPUAcceleration(currentMillis, client);
    updateMPUGyroscope(currentMillis, client);

    previousMillis = currentMillis;  //Clean to re-run cicle

    Serial.println("Ended cicle!");
  }
}
