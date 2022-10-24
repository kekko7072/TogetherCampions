#include <ArduinoBLE.h>
#include <Arduino_MKRGPS.h>
#include <Wire.h>
#include "configuration.h"
#include "system.h"
#include "mpu.h"
#include "gps.h"


//ORIGINAL POST FOR ARDUINO BLE: https://create.arduino.cc/editor/dpajak/e7af8e95-0aff-4ce1-b2f7-4e7b446c2577/preview

//THE MAXIMUM SIZE IS 20 BYTES AS SAID HERE https://stackoverflow.com/questions/24135682/android-sending-data-20-bytes-by-ble
// Bluetooth® Low Energy Battery Service
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
  BLE.setLocalName("TKR1A1");
  byte data[19] = { 0x00, 0x00, 0x46, 0x72, 0x61, 0x6e, 0x63, 0x65, 0x73, 0x63, 0x6f, 0x20, 0x56, 0x65, 0x7a, 0x7a, 0x61, 0x6e, 0x69 };
  BLE.setManufacturerData(data, 19);

  BLE.setAdvertisedService(systemService);
  BLE.setAdvertisedService(gpsService);
  BLE.setAdvertisedService(mpuService);

  systemService.addCharacteristic(systemCharacteristic);  // Timestamp characteristic
  gpsService.addCharacteristic(poitionCharacteristic);        // Gps characteristic
  gpsService.addCharacteristic(navigationCharacteristic);        // Acceleration characteristic
  mpuService.addCharacteristic(accelerometerCharacteristic);        // Acceleration characteristic
  mpuService.addCharacteristic(gyroscopeCharacteristic);        // Acceleration characteristic


  BLE.addService(systemService);  // System service
  BLE.addService(gpsService);     // Telemetry service
  BLE.addService(mpuService);     // Telemetry service



  BLE.advertise();  //start advertising the service

  // assign event handlers for connected, disconnected to peripheral
  BLE.setEventHandler(BLEConnected, ConnectHandler);
  BLE.setEventHandler(BLEDisconnected, DisconnectHandler);

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

float GPSPositionData[5];
float GPSNavigationData[5];

void loop() {

  BLEDevice central = BLE.central();  // wait for a Bluetooth® Low Energy central

  GPSPositionData[0] = millis();
  GPSPositionData[1] = GPS.available() ? 0 : 1.1;  //Passing custom values to make sure system works as espected
  GPSPositionData[2] = GPS.available() ? isnan(GPS.latitude()) ? 0.0 : GPS.latitude() : 0.0;
  GPSPositionData[3] = GPS.available() ? isnan(GPS.longitude()) ? 0.0 : GPS.longitude() : 0.0;
  GPSPositionData[4] = GPS.available() ? isnan(GPS.altitude()) ? 0.0 : GPS.altitude() : 0.0;

  GPSNavigationData[0] = millis();
  GPSNavigationData[1] = GPS.available() ? 0 : 1.1;  //Passing custom values to make sure system works as espected
  GPSNavigationData[2] = GPS.available() ? isnan(GPS.speed()) ? 0.0 : GPS.speed() : 0.0;
  GPSNavigationData[3] = GPS.available() ? isnan(GPS.course()) ? 0.0 : GPS.course() : 0;          // Track angle in degrees
  GPSNavigationData[4] = GPS.available() ? isnan(GPS.variation()) ? 0.0 : GPS.variation() : 0.0;  // Magnetic Variation


  if (central.connected()) {
    long currentMillis = millis();

    if (currentMillis - previousMillis >= measurements_milliseconds) {
      //System
      updateSystem(systemCharacteristic, currentMillis);

      //GPS
      poitionCharacteristic.setValue((byte *)&GPSPositionData, 20);
      navigationCharacteristic.setValue((byte *)&GPSNavigationData, 20);

      updateMpu(accelerometerCharacteristic, gyroscopeCharacteristic, currentMillis);


      Serial.println(GPSPositionData[1]);
      Serial.println(GPSPositionData[2], 7);
      Serial.println(GPSPositionData[3], 7);

      previousMillis = currentMillis;  //Clean to re-run cicle
    }
  }
}

void ConnectHandler(BLEDevice central) {
  // central connected event handler

  Serial.print("Connected event, central: ");
  Serial.println(central.address());

  BLE.advertise();
}

void DisconnectHandler(BLEDevice central) {
  // central disconnected event handlerù

  Serial.print("Disconnected event, central: ");
  Serial.println(central.address());

  BLE.advertise();
}