#ifndef GPS_CLASSES
#define GPS_CLASSES

void setupGPS() {
  Serial.print("Intializing  GPS:  ");  // Start the software serial port at the GPS's default baud
  Serial1.begin(9600);
  Serial.print("OK");
  Serial.println();
}

void updateGPS(BLECharacteristic position, BLECharacteristic navigation, TinyGPSPlus gps, TinyGPSCustom magneticVariation) {

  float GPSPositionData[5];
  GPSPositionData[0] = millis();
  GPSPositionData[1] = gps.location.isUpdated() ? 0 : 1;
  GPSPositionData[2] = gps.location.isUpdated() ? gps.location.lat() : 0.0;
  GPSPositionData[3] = gps.location.isUpdated() ? gps.location.lng() : 0.0;
  GPSPositionData[4] = gps.speed.isUpdated() ? gps.speed.knots() : 0.0;

  float GPSNavigationData[5];
  GPSNavigationData[0] = millis();
  GPSNavigationData[1] = gps.altitude.isUpdated() ? 0 : 1;
  GPSNavigationData[2] = gps.altitude.isUpdated() ? gps.altitude.meters() : 0.0;
  GPSNavigationData[3] = gps.course.isUpdated() ? gps.course.deg() : 0.0;                        // Track angle in degrees
  GPSNavigationData[4] = magneticVariation.isValid() ? atof(magneticVariation.value()) : 0.0;  // Magnetic Variation

  position.setValue((byte *)&GPSPositionData, 20);
  navigation.setValue((byte *)&GPSNavigationData, 20);

  /*String input_data = input_data + "&timestamp=" + String(millis()) + "&available=" + String(millis())
                      +  "&latitude=" + String(input.latitude[k], 7) + "&longitude=" + String(input.longitude[k], 7)
                      + "&altitude=" + String(input.altitude[k], 7) + "&speed=" + String(input.speed[k], 7) + "&course="
                      + String(input.course[k], 7) + "&satellites=" + String(input.satellites[k]);

  sdcard_save(String input_data);*/
}

#endif