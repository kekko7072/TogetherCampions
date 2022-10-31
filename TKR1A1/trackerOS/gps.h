#ifndef GPS_CLASSES
#define GPS_CLASSES


void setupGPS() {
  Serial.print("Intializing  GPS:  ");  // Start the software serial port at the GPS's default baud
  Serial1.begin(9600);
  Serial.print("OK");
  Serial.println();
}

void updateGPS(BLECharacteristic position, BLECharacteristic navigation, TinyGPSPlus gps, TinyGPSCustom magneticVariation) {
  if (Serial1.available() > 0) {
    if (gps.encode(Serial1.read())) {}
  }

  float GPSPositionData[5];
  float GPSNavigationData[5];

  GPSPositionData[0] = millis();
  GPSPositionData[1] = gps.location.isValid() ? 0 : 1;
  GPSPositionData[2] = gps.location.isValid() ? gps.location.lat() : 0.0;
  GPSPositionData[3] = gps.location.isValid() ? gps.location.lng() : 0.0;
  GPSPositionData[4] = gps.speed.isValid() ? gps.speed.kmph() : 0.0;  // Speed over the ground in kph

  GPSNavigationData[0] = millis();
  GPSNavigationData[1] = gps.altitude.isValid() ? 0 : 1;
  GPSNavigationData[2] = gps.altitude.isValid() ? gps.altitude.meters() : 0.0;
  GPSNavigationData[3] = gps.course.isValid() ? gps.course.deg() : 0.0;  // Track angle in degrees
  GPSNavigationData[4] = magneticVariation.isValid() ? atof(magneticVariation.value()): 0.0;                      // Magnetic Variation


  position.setValue((byte *)&GPSPositionData, 20);
  navigation.setValue((byte *)&GPSNavigationData, 20);
}

#endif