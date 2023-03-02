#include <ArduinoBLE.h>
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





//SERVICES
long previousMillis = 0;

//GPS
TinyGPSPlus gps;
TinyGPSCustom magneticVariation(gps, "GPRMC", 10);

UUID uuid;

//MPU
//Adafruit_MPU6050 mpu;
//sensors_event_t a, g, temp;

void setup() {

  //Initialize serial communication
  Serial.begin(9600);

  //Initialize the built-in LED
  pinMode(LED_BUILTIN, OUTPUT);

  //SDCARD
  initializeSDCARD(chip_select);

  //Bluetooth®
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1)
      ;
  }

  BLE.setDeviceName("TKR1A1");  //Setting a name that will appear when scanning for Bluetooth® devices
  BLE.setLocalName("TKR1A1");

  BLE.setAdvertisedService(systemService);
  BLE.setAdvertisedService(gpsService);
  BLE.setAdvertisedService(mpuService);

  systemService.addCharacteristic(systemCharacteristic);
  gpsService.addCharacteristic(poitionCharacteristic);
  gpsService.addCharacteristic(navigationCharacteristic);
  mpuService.addCharacteristic(accelerometerCharacteristic);
  mpuService.addCharacteristic(gyroscopeCharacteristic);

  BLE.addService(systemService);
  BLE.addService(gpsService);
  BLE.addService(mpuService);

  BLE.advertise();

  //BLE.setEventHandler(BLEConnected, ConnectHandler);
  //BLE.setEventHandler(BLEDisconnected, DisconnectHandler);

  //MPU-6050
  setupMPU();

  //GPS
  setupGPS();

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
  Serial.println(uuid);
  
  // wait for a Bluetooth® Low Energy central
  BLEDevice central = BLE.central();

  // If a central is connected to the peripheral:
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

        previousMillis = currentMillis;  //Clean to re-run cicle
      }
    }
    // If a central is not connected store data:
  } 
  /*else {
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

      previousMillis = currentMillis;  //Clean to re-run cicle
    }
  }*/
}