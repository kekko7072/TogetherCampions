#include <MKRGSM.h>
#include <MQTT.h>

//DEVICE
/*
  Device model number
*/
#define DEVICE_MODEL_NUMBER "TKR1B1"


/* 
  Sim parameters for connction of GPRS service
*/
#define SIM_PIN ""              //[WIND-TRE] "" || [Arduino] "0000" || [TIM] ""  || [THINGS MOBILE] 1503 not working
#define SIM_APN "iot.1nce.net"  // [WIND-TRE] "internet.it" || [Arduino] "prepay.pelion" || [TIM] "ibox.tim.it" || [THINGS MOBILE] TM not working
#define SIM_LOGIN ""            // replace with your GPRS login [Arduino] "arduino"
#define SIM_PASSWORD ""         // replace with your GPRS password [Arduino] "arduino"



/// ADVANCED SETTINGS

/*
  Server address and enpionds witch are used to store data on the cloud.
  Link to dashboard: https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
*/
#define MQTT_SERVER "firringer362.cloud.shiftr.io"  // broker, with shiftr.io it's "broker.shiftr.io"
#define MQTT_SERVER_PORT 1883                       // broker mqtt port
#define MQTT_SERVER_KEY "firringer362"              // broker key
#define MQTT_SERVER_SECRET "tw8hqY2Cx0v65tjp"       // broker secret


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