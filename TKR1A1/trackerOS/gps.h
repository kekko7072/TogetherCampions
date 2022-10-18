#include "sdcard_helper.h";

void updateGps(BLECharacteristic characteristic) {
  if (GPS.available()) {

    //5 Digits ok for 1 mt precizion (Max of GPS devices) https://medium.com/@malcolmteas/why-4-or-5-digits-of-gps-position-is-fine-de65af431253
    float eulers[5];
    eulers[0] = isnan(GPS.latitude()) ? 0.0 : GPS.latitude();
    eulers[1] = isnan(GPS.longitude()) ? 0.0 : GPS.longitude();
    eulers[2] = isnan(GPS.longitude()) ? 0.0 : GPS.speed();
    eulers[3] = isnan(GPS.longitude()) ? 0.0 : GPS.course();     // Track angle in degrees
    eulers[4] = isnan(GPS.longitude()) ? 0.0 : GPS.variation();  // Magnetic Variation

    // BLE Send 5x eulers over bluetooth as 1x byte array
    characteristic.setValue((byte *)&eulers, 12);

    //SDCARD Save
    // String input = "\"GPS\":{\"availavle\":" + String(GPS.available()) + "\"latitude\":" + String(eulers[0]) + ",\"longitude\":" + String(eulers[1]) + ",\"speed\":" + String(eulers[2]) + ",\"course\":" + String(eulers[3]) + ",\"variation\":" + String(eulers[4]) + "}";
    // sdcard_save(input);
  }
}