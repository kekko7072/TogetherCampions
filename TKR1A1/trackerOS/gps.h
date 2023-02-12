#ifndef GPS_CLASSES
#define GPS_CLASSES

#include "sdcard.h"

//INFO GPS: http://aprs.gids.nl/nmea/
void setupGPS() {
  Serial.print("Intializing  GPS:  ");  // Start the software serial port at the GPS's default baud
  Serial1.begin(9600);
  Serial.print("OK");
  Serial.println();
}

void updateGPSPosition(int timestamp, BLECharacteristic position, TinyGPSPlus gps) {

  float GPSPos[5];
  GPSPos[0] = timestamp;
  GPSPos[1] = gps.location.isValid();  // 0: FALSE, 1: TRUE
  GPSPos[2] = gps.location.isValid() ? gps.location.lat() : 0.0;
  GPSPos[3] = gps.location.isValid() ? gps.location.lng() : 0.0;
  GPSPos[4] = gps.speed.isValid() ? gps.speed.knots() : 0.0;

  //Send using BLE
  position.setValue((byte *)&GPSPos, 20);

  //Save on SDCARD
  String available = GPSPos[1] == 0.00 ? "false" : "true";
  String data = "GPS_POSITION;" + String(timestamp) + ";" + available + ";" + String(GPSPos[2], 7) + ";" + String(GPSPos[3], 7) + ";" + String(GPSPos[4], 7);
  sdcard_save(data);
}

void updateGPSNavigation(int timestamp, BLECharacteristic navigation, TinyGPSPlus gps, TinyGPSCustom magneticVariation) {

  float GPSNav[5];
  GPSNav[0] = timestamp;
  GPSNav[1] = gps.altitude.isValid();  // 0: FALSE, 1: TRUE
  GPSNav[2] = gps.altitude.isValid() ? gps.altitude.meters() : 0.0;
  GPSNav[3] = gps.course.isValid() ? gps.course.deg() : 0.0;                        // Track angle in degrees
  GPSNav[4] = magneticVariation.isValid() ? atof(magneticVariation.value()) : 0.0;  // Magnetic Variation

  //Send using BLE
  navigation.setValue((byte *)&GPSNav, 20);

  /*String input_data = input_data + "&timestamp=" + String(millis()) + "&available=" + String(millis())
                      +  "&latitude=" + String(input.latitude[k], 7) + "&longitude=" + String(input.longitude[k], 7)
                      + "&altitude=" + String(input.altitude[k], 7) + "&speed=" + String(input.speed[k], 7) + "&course="
                      + String(input.course[k], 7) + "&satellites=" + String(input.satellites[k]);

  sdcard_save(String input_data);*/

  //Save on SDCARD
  String available = GPSNav[1] == 0.00 ? "false" : "true";
  String data = "GPS_NAVIGATION;" + String(timestamp) + ";" + available + ";" + String(GPSNav[2], 4) + ";" + String(GPSNav[3], 4) + ";" + String(GPSNav[4], 4);
  sdcard_save(data);
}

#endif