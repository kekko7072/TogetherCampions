#include <ArduinoBLE.h>

//DEVICE
/*
  Device model number
*/
#define DEVICE_MODEL_NUMBER "TKR1A1"

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

void connectBLE() {
  //BLE
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1)
      ;
  }

  BLE.setDeviceName(DEVICE_MODEL_NUMBER);  //Setting a name that will appear when scanning for Bluetooth® devices
  BLE.setLocalName(DEVICE_MODEL_NUMBER);

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

double randomDouble(double minf, double maxf) {
  return minf + random(1UL << 31) * (maxf - minf) / (1UL << 31);  // use 1ULL<<63 for max double values)
}