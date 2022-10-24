#include <ArduinoBLE.h>
#include <Arduino_MKRGPS.h>
#include <Wire.h>
#include <QMC5883LCompass.h>
#include "configuration.h"
#include "system.h"
#include "battery.h"
#include "mpu.h"
#include "compass.h"
#include "gps.h"
#include "tca.h"


//ORIGINAL POST FOR ARDUINO BLE: https://create.arduino.cc/editor/dpajak/e7af8e95-0aff-4ce1-b2f7-4e7b446c2577/preview


// Bluetooth® Low Energy Battery Service
BLEService systemService("00001000-0000-1000-8000-00805F9B34FB");

BLECharacteristic systemCharacteristic("00001001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);     //TIMESTAMP 1001 4 bit
//BLECharacteristic batteryLevelCharacteristic("00001002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 8);  //BATTERY LEVEL 1002 8 bit
//BLECharacteristic temperatureCharacteristic("00001003-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 8);   //TEMPERATURE 1003 8 bit


// Telemetry
BLEService telemetryService("00002000-0000-1000-8000-00805F9B34FB");

BLECharacteristic gpsCharacteristic("00002001-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 20);            //GPS 2005 1 bit
BLECharacteristic mpuCharacteristic("00002002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 28);  //MPU 2001 28 bit
//BLECharacteristic speedCharacteristic("00002002-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);          //SPEED 2002
//BLECharacteristic gyroscopeCharacteristic("00002003-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 16);  //GYROSCOPE 2003 16 bit
//BLECharacteristic compassCharacteristic("00002004-0000-1000-8000-00805F9B34FB", BLERead | BLENotify, 12);        //COMPASS 2004



//SERVICES
long previousMillis = 0;


void setup() {

  Serial.begin(9600);  // initialize serial communication
  /*while (!Serial)
      ;  //starts the program if we open the serial monitor.
      */


  pinMode(LED_BUILTIN, OUTPUT);  // initialize the built-in LED pin to indicate when a central is connected

  //SDCARD
  //bool sdCard_available = initializationSDCARD(chip_select);
  //Serial.print(sdCard_available == 0 ? "FALSE" : "TRUE");

  //BLE
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1)
      ;
  }


  // set advertised local name and service UUID:
  BLE.setDeviceName("TKR1A1");  //Setting a name that will appear when scanning for Bluetooth® devices
  byte data[19] = { 0x00, 0x00, 0x46, 0x72, 0x61, 0x6e, 0x63, 0x65, 0x73, 0x63, 0x6f, 0x20, 0x56, 0x65, 0x7a, 0x7a, 0x61, 0x6e, 0x69 };
  BLE.setManufacturerData(data, 19);

  BLE.setAdvertisedService(systemService);
  BLE.setAdvertisedService(telemetryService);

  systemService.addCharacteristic(systemCharacteristic);     // Timestamp characteristic
  //systemService.addCharacteristic(batteryLevelCharacteristic);  // BatteryLevel characteristic
  //systemService.addCharacteristic(temperatureCharacteristic);   // Temperature characteristic

  telemetryService.addCharacteristic(gpsCharacteristic);            // Gps characteristic
  telemetryService.addCharacteristic(mpuCharacteristic);  // Acceleration characteristic
  //telemetryService.addCharacteristic(speedCharacteristic);          // Speed characteristic
  //telemetryService.addCharacteristic(gyroscopeCharacteristic);  // Gyroscope characteristic
  //telemetryService.addCharacteristic(compassCharacteristic);        // Gyroscope characteristic



  BLE.addService(systemService);     // System service
  BLE.addService(telemetryService);  // Telemetry service



  // batteryLevelChar.writeValue(oldBatteryLevel);  // set initial value for this characteristic


  BLE.advertise();  //start advertising the service

  Wire.begin();
  delay(100);

  //MPU-6050
  setupMPU();

  //GY-271

  //GPS

  /*
  !!!GPS USING I2C IS MAKING DEVICE NOT WORKING ON REBOOT 
  AFTHER TEST PASS ON BEGIN GPS.begin(GPS_MODE_SHIELD) so it will work on reboot.
  1)Soder the given pin to the GPS board
  2)Test mounting the shield as hat to arduino mkr
  3)Test on rebot using sampel created on desktop (GPS_TEST)
*/
  Serial.print("Intializing  GPS:  ");
  if (!GPS.begin(GPS_MODE_SHIELD)) {
    Serial.println("Failed to initialize GPS!");
    while (1)
      ;
  }
  Serial.print("OK");
  Serial.println();


  Serial.println(" Bluetooth® device active, waiting for connections...");
}

float GPSData[5];

void loop() {

  BLEDevice central = BLE.central();  // wait for a Bluetooth® Low Energy central

  GPSData[0] = GPS.available() ? 0.0 : 1.1;  //Passing custom values to make sure system works as espected
  GPSData[1] = GPS.available() ? isnan(GPS.latitude()) ? 0.0 : GPS.latitude() : 0.0;
  GPSData[2] = GPS.available() ? isnan(GPS.longitude()) ? 0.0 : GPS.longitude() : 0.0;
  GPSData[3] = GPS.available() ? isnan(GPS.longitude()) ? 0.0 : GPS.speed() : 0.0;
  //  eulers[3] = GPS.available() ? isnan(GPS.longitude()) ? 0.0 : GPS.course(): 0.0;    // Track angle in degrees
  // eulers[4] = GPS.available() ? isnan(GPS.longitude()) ? 0.0 : GPS.variation(): 0.0;  // Magnetic Variation
  GPSData[4] = millis();


  if (central.connected()) {
    long currentMillis = millis();

    if (currentMillis - previousMillis >= measurements_milliseconds) {
      //System
      //systemCharacteristic.setValue((byte *)&currentMillis, 4);
      updateSystem(systemCharacteristic, currentMillis);
      //updateTemperature(temperatureCharacteristic, currentMillis);

      //Telemetry
      updateMpu(mpuCharacteristic, currentMillis);
      //updateSpeed(currentMillis - previousMillis, speedCharacteristic);
      //updateGyroscope(gyroscopeCharacteristic, currentMillis);
      //updateCompass(compassCharacteristic);
      //updateGps(gpsCharacteristic, gps_data);
      gpsCharacteristic.setValue((byte *)&GPSData, 20);

      previousMillis = currentMillis;  //Clean to re-run cicle
    }
  }
}