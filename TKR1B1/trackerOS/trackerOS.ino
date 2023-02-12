#include <MKRGSM.h>
#include <MQTT.h>
#include "configuration.h"


GSMClient net;
GPRS gprs;
GSM gsmAccess;
MQTTClient client;

unsigned long lastMillis = 0;

void connect() {
  while (!Serial)
    ;
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
  while (!client.connect("TKR1A1", MQTT_SERVER_KEY, MQTT_SERVER_SECRET)) {
    Serial.print(".");
    delay(1000);
  }

  Serial.println("\nconnected!");

  client.subscribe("/timestamp");
  // client.unsubscribe("/hello");
}

void messageReceived(String &topic, String &payload) {
  Serial.println("incoming: " + topic + " - " + payload);

  // Note: Do not use the client in the callback to publish, subscribe or
  // unsubscribe as it may cause deadlocks when other things arrive while
  // sending and receiving acknowledgments. Instead, change a global variable,
  // or push to a queue and handle it in the loop after calling `client.loop()`.
}

void setup() {
  Serial.begin(9600);

  // Note: Local domain names (e.g. "Computer.local" on OSX) are not supported
  // by Arduino. You need to set the IP address directly.
  //client.begin("broker.shiftr.io", net);
  client.onMessage(messageReceived);

  connect();
}

void loop() {
  client.loop();

  if (!client.connected()) {
    connect();
  }

  // Publish a message roughly every 500 millisecond.
  if (millis() - lastMillis > 500) {
    lastMillis = millis();
    client.publish("/AAA000AAA/timestamp", String(millis()));
    client.publish("/AAA000AAA/latitude", String(32.32));
    client.publish("/AAA000AAA/longitude", String(322.32));
    client.publish("/AAA000AAA/speed", String(5.32));
  }
}