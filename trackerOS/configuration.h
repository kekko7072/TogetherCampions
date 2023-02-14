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

//DEVICE
/*
  Device model: 
    + 0: TKR1B1 SIM 
    + 1: TKR1A1 BLE
*/
#define DEVICE_MODEL 1

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