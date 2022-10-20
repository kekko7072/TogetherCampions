#include "constants.h"

void updateBatteryLevel(BLECharacteristic characteristic) {
  /* Read the current voltage level on the A0 analog input pin.
     This is used here to simulate the charge level of a battery.
  */
  float voltage = analogRead(ADC_BATTERY) * 5.0 / 1023;  //(4.3 / 1023.0)
  int batteryLevel = map(voltage, 3.6, 4.2, 0, 100);

  // if (batteryLevel != oldBatteryLevel) {
  // if the battery level has changed
  Serial.print("Battery Level % is now: ");  // print it
  Serial.println(batteryLevel);


  characteristic.setValue((byte *)&batteryLevel, 12);
  //oldBatteryLevel = batteryLevel;  // save the level for next comparison
  //  }
}