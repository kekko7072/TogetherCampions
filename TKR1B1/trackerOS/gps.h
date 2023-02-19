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

char* outputStringGPSPos(float (&GPSPos)[5]) {
  const char* available = GPSPos[1] == 0.00 ? "false" : "true";
  char* result = (char*)malloc(100);
  snprintf(result, 100, "GPS_POSITION;%.2f;%s;%.4f;%.4f;%.4f", GPSPos[0], available, GPSPos[2], GPSPos[3], GPSPos[4]);
  return result;
}
char* outputStringGPSNav(float (&GPSNav)[5]) {
  const char* available = GPSNav[1] == 0.00 ? "false" : "true";
  char* result = (char*)malloc(100);
  snprintf(result, 100, "GPS_NAVIGATION;%.2f;%s;%.4f;%.4f;%.4f", GPSNav[0], available, GPSNav[2], GPSNav[3], GPSNav[4]);
  return result;
}

void updateGPSPosition(int timestamp, MQTTClient client, TinyGPSPlus gps) {

  float GPSPos[5];
  GPSPos[0] = timestamp;
  GPSPos[1] = gps.location.isValid();  // 0: FALSE, 1: TRUE
  GPSPos[2] = gps.location.isValid() ? gps.location.lat() : 0.0;
  GPSPos[3] = gps.location.isValid() ? gps.location.lng() : 0.0;
  GPSPos[4] = gps.speed.isValid() ? gps.speed.knots() : 0.0;

  //Send using MQTT
  String topicPath = "/" + String(DEVICE_SERIAL_NUMBER) + "/GPS_POSITION";
  client.publish(topicPath, outputStringGPSPos(GPSPos));

  //Save on SDCARD
  sdcard_save(outputStringGPSPos(GPSPos));
}

void updateGPSNavigation(int timestamp, MQTTClient client, TinyGPSPlus gps, TinyGPSCustom magneticVariation) {

  float GPSNav[5];
  GPSNav[0] = timestamp;
  GPSNav[1] = gps.altitude.isValid();  // 0: FALSE, 1: TRUE
  GPSNav[2] = gps.altitude.isValid() ? gps.altitude.meters() : 0.0;
  GPSNav[3] = gps.course.isValid() ? gps.course.deg() : 0.0;                        // Track angle in degrees
  GPSNav[4] = magneticVariation.isValid() ? atof(magneticVariation.value()) : 0.0;  // Magnetic Variation

  //Send using MQTT
  String topicPath = "/" + String(DEVICE_SERIAL_NUMBER) + "/GPS_NAVIGATION";
  client.publish(topicPath, outputStringGPSNav(GPSNav));

  //Save on SDCARD
  sdcard_save(outputStringGPSNav(GPSNav));
}

#endif
