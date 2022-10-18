#include <ArduinoBLE.h>
#include <Arduino_MKRGPS.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include "timestamp.h"
#include "battery.h"
#include "mpu.h"
#include "gps.h"

//ORIGINAL POST FOR ARDUINO BLE: https://create.arduino.cc/editor/dpajak/e7af8e95-0aff-4ce1-b2f7-4e7b446c2577/preview


// Bluetooth® Low Energy Battery Service
BLEService systemService("00001000-0000-1000-8000-00805F9B34FB");

BLECharacteristic timestampCharacteristic("00001001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);     //TIMESTAMP 1001
BLECharacteristic batteryLevelCharacteristic("00001002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);  //BATTERY LEVEL 1002
BLECharacteristic temperatureCharacteristic("00001003-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);   //TEMPERATURE 1003


// Telemetry
BLEService telemetryService("00002000-0000-1000-8000-00805F9B34FB");

BLECharacteristic accelerometerCharacteristic("00002001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);  //ACCELERATION 2001
BLECharacteristic speedCharacteristic("00002002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);          //SPEED 2002
BLECharacteristic gyroscopeCharacteristic("00002003-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);      //GYROSCOPE 2003
BLECharacteristic gpsCharacteristic("00002004-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);            //GPS 2004


//SERVICES
long previousMillis = 0;
long totalMillis = 0;

//BATTERY
int oldBatteryLevel = 0;

//MPU-6050
const int MPU = 0x68;  // I2C address of the MPU-6050



void setup() {
  if (debug_mode) {
    Serial.begin(9600);  // initialize serial communication
    /*while (!Serial)
      ;  //starts the program if we open the serial monitor.
      */
  }

  pinMode(LED_BUILTIN, OUTPUT);  // initialize the built-in LED pin to indicate when a central is connected

  //SDCARD
  //bool sdCard_available = initializationSDCARD(chip_select);
  //Serial.print(sdCard_available == 0 ? "FALSE" : "TRUE");

  //BLE
  if (!BLE.begin()) {
    if (debug_mode)
      Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1)
      ;
  }
  BLE.setEventHandler(BLEConnected, ConnectHandler);
  BLE.setEventHandler(BLEDisconnected, DisconnectHandler);

  // set advertised local name and service UUID:
  BLE.setDeviceName("TKR1A1");  //Setting a name that will appear when scanning for Bluetooth® devices
  byte data[19] = { 0x00, 0x00, 0x46, 0x72, 0x61, 0x6e, 0x63, 0x65, 0x73, 0x63, 0x6f, 0x20, 0x56, 0x65, 0x7a, 0x7a, 0x61, 0x6e, 0x69 };
  BLE.setManufacturerData(data, 19);

  BLE.setAdvertisedService(systemService);
  BLE.setAdvertisedService(telemetryService);

  systemService.addCharacteristic(timestampCharacteristic);     // Timestamp characteristic
  systemService.addCharacteristic(batteryLevelCharacteristic);  // BatteryLevel characteristic
  systemService.addCharacteristic(temperatureCharacteristic);   // Temperature characteristic

  telemetryService.addCharacteristic(accelerometerCharacteristic);  // Acceleration characteristic
  telemetryService.addCharacteristic(speedCharacteristic);          // Speed characteristic
  telemetryService.addCharacteristic(gyroscopeCharacteristic);      // Gyroscope characteristic
  telemetryService.addCharacteristic(gpsCharacteristic);            // Gps characteristic


  BLE.addService(systemService);     // System service
  BLE.addService(telemetryService);  // Telemetry service



  // batteryLevelChar.writeValue(oldBatteryLevel);  // set initial value for this characteristic


  BLE.advertise();  //start advertising the service



  //MPU-6050
  Wire.begin();
  Wire.beginTransmission(MPU);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

  //GPS
  if (debug_mode)
    Serial.print("Intializing  GPS:  ");
  if (!GPS.begin()) {
    if (debug_mode)
      Serial.println("Failed to initialize GPS!");
    while (1)
      ;
  }
  if (debug_mode) {
    Serial.print("OK");
    Serial.println();
  }

  if (debug_mode)
    Serial.println(" Bluetooth® device active, waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();  // wait for a Bluetooth® Low Energy central
  //BLE.poll();
  if (central) {  // if a central is connected to the peripheral
    if (debug_mode) {
      Serial.print("Connected to central: ");
      Serial.println(central.address());  // print the central's BT address
    }

    digitalWrite(LED_BUILTIN, HIGH);  // turn on the LED to indicate the connection

    // while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();

      if (currentMillis - previousMillis >= measurements_milliseconds) {
        //System
        updateTimestamp(timestampCharacteristic);
        updateBatteryLevel(batteryLevelCharacteristic, oldBatteryLevel);
        updateTemperature(temperatureCharacteristic, MPU);

        //Telemetry
        updateAcceleration(accelerometerCharacteristic, MPU);
        updateSpeed(currentMillis - previousMillis, speedCharacteristic, MPU);
        updateGyroscope(gyroscopeCharacteristic, MPU);
        updateGps(gpsCharacteristic);

        previousMillis = currentMillis;  //Clean to re-run cicle
      }
    }
    //Disconnected
    digitalWrite(LED_BUILTIN, LOW);
    if (debug_mode) {
      Serial.print("Disconnected from central: ");
      Serial.println(central.address());
    }
  }
}

void ConnectHandler(BLEDevice central) {
  // central connected event handler
  if (debug_mode) {
    Serial.print("Connected event, central: ");
    Serial.println(central.address());
  }
  BLE.advertise();
}

void DisconnectHandler(BLEDevice central) {
  // central disconnected event handlerù
  if (debug_mode) {
    Serial.print("Disconnected event, central: ");
    Serial.println(central.address());
  }
  BLE.advertise();
}