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
  Device model number
*/
#define DEVICE_MODEL_NUMBER "TKR1B1"
/*
  Set a new device_id unique for every new device released using AAAA0000AAAA scheme (URL ENDPOINT TO GENERATE).
  The SERIAL_NUMBER should be printed and given to the user to configure the device for his account.
*/
#define DEVICE_SERIAL_NUMBER "AAAA0000AAAA"


/* 
  Sim parameters for connction of GPRS service
*/
#define SIM_PIN ""              //[WIND-TRE] "" || [Arduino] "0000" || [TIM] ""  || [THINGS MOBILE] 1503 not working
#define SIM_APN "iot.1nce.net"  // [WIND-TRE] "internet.it" || [Arduino] "prepay.pelion" || [TIM] "ibox.tim.it" || [THINGS MOBILE] TM not working
#define SIM_LOGIN ""            // replace with your GPRS login [Arduino] "arduino"
#define SIM_PASSWORD ""         // replace with your GPRS password [Arduino] "arduino"



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

/*
  Server address and enpionds witch are used to store data on the cloud.
  Link to dashboard: https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
*/
#define MQTT_SERVER "firringer362.cloud.shiftr.io"  // broker, with shiftr.io it's "broker.shiftr.io"
#define MQTT_SERVER_PORT 1883                       // broker mqtt port
#define MQTT_SERVER_KEY "firringer362"              // broker key
#define MQTT_SERVER_SECRET "tw8hqY2Cx0v65tjp"       // broker secret

#include <MKRGSM.h>
#include <MQTT.h>

void connectMQTT(GSMClient net, GPRS gprs, GSM gsmAccess, MQTTClient client) {
  Serial.print("Connecting to cellular network ...");

  bool connected = false;

  // After starting the modem with gsmAccess.begin()
  // attach to the GPRS network with the APN, login and password
  while (!connected) {
    if ((gsmAccess.begin(SIM_PIN) == GSM_READY) && (gprs.attachGPRS(SIM_APN, SIM_LOGIN, SIM_PASSWORD) == GPRS_READY)) {
      connected = true;
    } else {
      Serial.print(".");
      delay(1000);
    }
  }
  client.begin(MQTT_SERVER, MQTT_SERVER_PORT, net);


  Serial.print("\nConnecting to MQTT ...");
  while (!client.connect(DEVICE_SERIAL_NUMBER, MQTT_SERVER_KEY, MQTT_SERVER_SECRET)) {
    Serial.print(".");
    delay(1000);
  }

  Serial.println("\nconnected!");

  client.subscribe("/timestamp");
}