#include <ArduinoBLE.h>
#include <TinyGPS++.h>
//#include <Adafruit_MPU6050.h>
//#include <Adafruit_Sensor.h>
#include <Wire.h>
#include "configuration.h"
#include "system.h"
#include "mpu.h"
#include "gps.h"





//SERVICES
long previousMillis = 0;

//GPS
TinyGPSPlus gps;
TinyGPSCustom magneticVariation(gps, "GPRMC", 10);

//MPU
//Adafruit_MPU6050 mpu;
//sensors_event_t a, g, temp;

void setup() {

  //Initialize serial communication
  Serial.begin(9600);

  //Initialize the built-in LED
  pinMode(LED_BUILTIN, OUTPUT);

  //Bluetooth®
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1)
      ;
  }

  initializationBLE();

  BLE.setEventHandler(BLEConnected, ConnectHandler);
  BLE.setEventHandler(BLEDisconnected, DisconnectHandler);

  //MPU-6050
  setupMPU();

  //GPS
  setupGPS();

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {
  BLE.central();

  long currentMillis = millis();

  while (Serial1.available() > 0) {
    gps.encode(Serial1.read());
    //Serial.println("@: GPSA AVAILABLE");
    //Serial.write(Serial1.read());
  }

  //mpu.getEvent(&a, &g, &temp);

  if (currentMillis - previousMillis >= measurements_milliseconds) {
    //System
    updateSystem(systemCharacteristic);

    //GPS
    updateGPS(poitionCharacteristic, navigationCharacteristic, gps, magneticVariation);

    //MPU
    updateMPU(accelerometerCharacteristic, gyroscopeCharacteristic);

    previousMillis = currentMillis;  //Clean to re-run cicle
  }
}