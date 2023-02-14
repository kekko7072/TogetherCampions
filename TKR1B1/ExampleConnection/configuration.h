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

/*
  CLOCK: Is the time the code run in loop fetching data from GPS to SERVER [aproximatly]. 
    Ex. clock = 60  Means run 60 times then data are send
*/


/* 
  Sim parameters for connction of GPRS service
*/
#define SIM_PIN ""   //[WIND-TRE] "" || [Arduino] "0000" || [TIM] ""  || [THINGS MOBILE] 1503 not working
#define SIM_APN "iot.1nce.net"     // [WIND-TRE] "internet.it" || [Arduino] "prepay.pelion" || [TIM] "ibox.tim.it" || [THINGS MOBILE] TM not working
#define SIM_LOGIN ""     // replace with your GPRS login [Arduino] "arduino" 
#define SIM_PASSWORD ""  // replace with your GPRS password [Arduino] "arduino" 



/// ADVANCED SETTINGS

/*
  Server address and enpionds witch are used to store data on the cloud.
  Link to dashboard: https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
*/
#define MQTT_SERVER "firringer362.cloud.shiftr.io"  // broker, with shiftr.io it's "broker.shiftr.io"
#define MQTT_SERVER_PORT 1883                       // broker mqtt port
#define MQTT_SERVER_KEY "firringer362"              // broker key
#define MQTT_SERVER_SECRET "tw8hqY2Cx0v65tjp"       // broker secret