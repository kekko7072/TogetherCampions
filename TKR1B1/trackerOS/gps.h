#ifndef GPS_CLASSES
#define GPS_CLASSES

#include "sdcard.h"
#include <MQTT.h>

//INFO GPS: http://aprs.gids.nl/nmea/
void setupGPS() {
  Serial.print("Intializing  GPS:  ");  // Start the software serial port at the GPS's default baud
  Serial1.begin(9600);
  Serial.print("OK");
  Serial.println();
}

String outputStringGPSPos(float (&GPSPos)[5]) {
  const String available = GPSPos[1] == 0.00 ? "false" : "true";
  /* char* result = (char*)malloc(100);
  snprintf(result, 100, "GPS_POSITION;%.2f;%s;%.4f;%.4f;%.4f", GPSPos[0], available, GPSPos[2], GPSPos[3], GPSPos[4]);
  return result;*/
  return "GPS_POSITION;" + String(GPSPos[0]) + ";" + available + ";" + String(GPSPos[1]) + ";" + String(GPSPos[2]) + ";" + String(GPSPos[3]) + ";" + String(GPSPos[4]);
}
String outputStringGPSNav(float (&GPSNav)[5]) {
  const String available = GPSNav[1] == 0.00 ? "false" : "true";
  //char* result = (char*)malloc(100);
  //snprintf(result, 100, "GPS_NAVIGATION;%.2f;%s;%.4f;%.4f;%.4f", GPSNav[0], available, GPSNav[2], GPSNav[3], GPSNav[4]);
  return "GPS_NAVIGATION;" + String(GPSNav[0]) + ";" + available + ";" + String(GPSNav[1]) + ";" + String(GPSNav[2]) + ";" + String(GPSNav[3]) + ";" + String(GPSNav[4]);
}

void updateGPSPosition(int timestamp, MQTTClient client, TinyGPSPlus gps) {

  float GPSPos[5];
  GPSPos[0] = timestamp;
  GPSPos[1] = gps.location.isValid();  // 0: FALSE, 1: TRUE
  GPSPos[2] = gps.location.isValid() ? gps.location.lat() : 0.0;
  GPSPos[3] = gps.location.isValid() ? gps.location.lng() : 0.0;
  GPSPos[4] = gps.speed.isValid() ? gps.speed.knots() : 0.0;

  //Send using MQTT
  char topic[50];
  sprintf(topic, "/%s/GPS_POSITION", DEVICE_SERIAL_NUMBER);
  char payload[50];
  sprintf(payload, "GPS_POSITION;%.6f;%.6f;%.6f;%.6f;%.6f", GPSPos[0], GPSPos[1], GPSPos[2], GPSPos[3], GPSPos[4]);
  client.publish(topic, payload);

  //Save on SDCARD
  sdcard_save(payload);
}

void updateGPSNavigation(int timestamp, MQTTClient client, TinyGPSPlus gps, TinyGPSCustom magneticVariation) {

  float GPSNav[5];
  GPSNav[0] = timestamp;
  GPSNav[1] = gps.altitude.isValid();  // 0: FALSE, 1: TRUE
  GPSNav[2] = gps.altitude.isValid() ? gps.altitude.meters() : 0.0;
  GPSNav[3] = gps.course.isValid() ? gps.course.deg() : 0.0;                        // Track angle in degrees
  GPSNav[4] = magneticVariation.isValid() ? atof(magneticVariation.value()) : 0.0;  // Magnetic Variation

  //Send using MQTT
  char topic[50];
  sprintf(topic, "/%s/GPS_NAVIGATION", DEVICE_SERIAL_NUMBER);
  char payload[50];
  sprintf(payload, "GPS_NAVIGATION;%.6f;%.6f;%.6f;%.6f;%.6f", GPSNav[0], GPSNav[1], GPSNav[2], GPSNav[3], GPSNav[4]);
  client.publish(topic, payload);

  //Save on SDCARD
  //sdcard_save(payload);
}

#endif
