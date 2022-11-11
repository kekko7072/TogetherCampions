/*
  
  Tracker Operative System [trackerOS]
  
  Version:  1.0.0
  Description:  This software is designed to solve all the relaiability problems given by the usage of JSON as object in traker_async_JSON.ino,
                as mentioned in this doc https://arduinojson.org/v6/issues/memory-leak/#why-does-this-happen so are replaced with arrays.

*/
//SOFTWARE
/*
  Software release name, is used as query so remember to insert no space
*/
#define SOFTWARE_NAME "trackerOS"
/*
  Software version, is used as query so remember to insert no space
*/
#define SOFTWARE_VERSION "1.0.0"
/*
  Define if is debugmode or not
*/
//#define SOFTWARE_DEBUG_MODE false

//DEVICE
/*
  Device model number
*/
#define DEVICE_MODEL_NUMBER "TKR1A1"

/*
  Set a new device_id unique for every new device released using AAAA0000AAAA scheme (URL ENDPOINT TO GENERATE).
  The SERIAL_NUMBER should be printed and given to the user to configure the device for his account.
*/
#define DEVICE_SERIAL_NUMBER "AAAA0000AAAA"






/// ADVANCED SETTINGS
//MUX
#define MUX_ADDR 0x70  // TCA9548A Encoders address
//MPU-6050
#define MPU_ADDR 0x68  // I2C address of the MPU-6050
//COMPASS
#define HMC5883L_ADDR 0x1E  //0011110b, I2C 7bit address of HMC5883
/*
  Define time between each measurements in ms
*/
#define measurements_milliseconds 500
/*
  SD CARD chip protocol
*/
#define chip_select 4

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