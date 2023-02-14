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





#if DEVICE_MODEL == 0
#include <MKRGSM.h>
#include <MQTT.h>
#include "configuration_sim.h"
GSMClient net;
GPRS gprs;
GSM gsmAccess;
MQTTClient client;

#else if DEVICE_MODEL == 1
#include <ArduinoBLE.h>
#include "configuration_ble.h"

#endif



//SERVICES
long previousMillis = 0;

//GPS
TinyGPSPlus gps;
TinyGPSCustom magneticVariation(gps, "GPRMC", 10);

UUID uuid;



#if DEVICE_MODEL == 0

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


#else DEVICE_MODEL == 1

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

  //BLE
  connectBLE();

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
  Serial.println(uuid);
  // wait for a Bluetooth® Low Energy central
  BLEDevice central = BLE.central();

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's BT address:
    Serial.println(central.address());

    // check the battery level every 200ms
    // while the central is connected:
    while (central.connected()) {

      long currentMillis = millis();

      while (Serial1.available() > 0) {
        gps.encode(Serial1.read());
      }

      //mpu.getEvent(&a, &g, &temp);

      if (currentMillis - previousMillis >= measurements_milliseconds) {

        //System
        updateSystem(currentMillis, systemCharacteristic);

        //GPS
        updateGPSPosition(currentMillis, poitionCharacteristic, gps);
        updateGPSNavigation(currentMillis, navigationCharacteristic, gps, magneticVariation);

        //MPU
        updateMPUAcceleration(currentMillis, accelerometerCharacteristic);
        updateMPUGyroscope(currentMillis, gyroscopeCharacteristic);
      }
      previousMillis = currentMillis;  //Clean to re-run cicle
    }
  }
}

#endif