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

  BLE.setDeviceName("TKR1A1");  //Setting a name that will appear when scanning for Bluetooth® devices
  BLE.setLocalName("TKR1A1");
  byte data[19] = { 0x00, 0x00, 0x46, 0x72, 0x61, 0x6e, 0x63, 0x65, 0x73, 0x63, 0x6f, 0x20, 0x56, 0x65, 0x7a, 0x7a, 0x61, 0x6e, 0x69 };
  BLE.setManufacturerData(data, 19);

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
  BLE.poll();

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