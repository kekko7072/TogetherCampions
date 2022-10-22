#include "sdcard_helper.h";

void updateGps(BLECharacteristic characteristic, int one) {
  //if (GPS.available()) {
    //5 Digits ok for 1 mt precizion (Max of GPS devices) https://medium.com/@malcolmteas/why-4-or-5-digits-of-gps-position-is-fine-de65af431253
  /*  float eulers[6];
    eulers[0] = isnan(GPS.latitude()) ? 0.0 : GPS.latitude();
    eulers[1] = isnan(GPS.longitude()) ? 0.0 : GPS.longitude();
    eulers[2] = isnan(GPS.longitude()) ? 0.0 : GPS.speed();
    eulers[3] = isnan(GPS.longitude()) ? 0.0 : GPS.course();     // Track angle in degrees
    eulers[4] = isnan(GPS.longitude()) ? 0.0 : GPS.variation();  // Magnetic Variation
    eulers[5] = millis();*/
    // print GPS values
    
    /*Serial.print(gps_data[0], 7);
    Serial.print(", ");
    Serial.println(gps_data[1], 7);

    Serial.print("Ground speed: ");
    Serial.print(gps_data[2]);
    Serial.println(" km/h");

    //Serial.print("Course: ");
    //Serial.print(eulers[3]);
    //Serial.println("m");

   // Serial.print("Variation: ");
    //Serial.println(eulers[4]);

    Serial.print("Millis: ");
    Serial.println(gps_data[3]);*/

    // BLE Send 5x eulers over bluetooth as 1x byte array
    characteristic.setValue((byte *)&one, 16);

    //SDCARD Save
    // String input = "\"GPS\":{\"availavle\":" + String(GPS.available()) + "\"latitude\":" + String(eulers[0]) + ",\"longitude\":" + String(eulers[1]) + ",\"speed\":" + String(eulers[2]) + ",\"course\":" + String(eulers[3]) + ",\"variation\":" + String(eulers[4]) + "}";
    // sdcard_save(input);
  /*}else{
    Serial.println("GPS NOT AVAILABLE");
  }*/
}