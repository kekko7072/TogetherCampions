#include <ArduinoBLE.h>
#include <TinyGPSPlus.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include "configuration.h"
#include "system.h"
#include "mpu.h"
#include "gps.h"


//ORIGINAL POST FOR ARDUINO BLE: https://create.arduino.cc/editor/dpajak/e7af8e95-0aff-4ce1-b2f7-4e7b446c2577/preview

//THE MAXIMUM SIZE IS 20 BYTES AS SAID HERE https://stackoverflow.com/questions/24135682/android-sending-data-20-bytes-by-ble
BLEService systemService("00001000-0000-1000-8000-00805F9B34FB");
BLECharacteristic systemCharacteristic("00001001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);  //SYSTEM 1001

// GPS
BLEService gpsService("00002000-0000-1000-8000-00805F9B34FB");
BLECharacteristic poitionCharacteristic("00002001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 20);     //GPS 2001
BLECharacteristic navigationCharacteristic("00002002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 20);  //GPS 2001

BLEService mpuService("00003000-0000-1000-8000-00805F9B34FB");
BLECharacteristic accelerometerCharacteristic("00003001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 16);  //MPU 2002
BLECharacteristic gyroscopeCharacteristic("00003002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 16);      //MPU 2002


//SERVICES
long previousMillis = 0;

//GPS
TinyGPSPlus gps;
TinyGPSCustom magneticVariation(gps, "GPRMC", 10);

//MPU
Adafruit_MPU6050 mpu;
sensors_event_t a, g, temp;

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
  setupMPU(mpu);

  //GPS
  setupGPS();

  //READY
  digitalWrite(LED_BUILTIN, HIGH);
}

void loop() {

  BLEDevice central = BLE.central();  // Wait for a Bluetooth® Low Energy central

  //if (central) {
  //digitalWrite(LED_BUILTIN, HIGH);

  //BLE.poll();

  //while (central.connected()) {

  long currentMillis = millis();

  if (Serial1.available() > 0) {
    if (gps.encode(Serial1.read())) {}
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
  
  //}
  //digitalWrite(LED_BUILTIN, LOW);
  //}
}
