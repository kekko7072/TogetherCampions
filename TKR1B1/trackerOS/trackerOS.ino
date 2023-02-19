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

  //MQTT
  connectMQTT(net, gprs, gsmAccess, client);

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
  Serial.println(uuid);

  client.loop();

  if (!client.connected()) {
    connectMQTT(net, gprs, gsmAccess, client);
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
  }
}
