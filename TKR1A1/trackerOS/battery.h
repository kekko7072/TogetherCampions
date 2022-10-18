#include "constants.h"

void updateBatteryLevel(BLECharacteristic characteristic, int oldBatteryLevel) {
  /* Read the current voltage level on the A0 analog input pin.
     This is used here to simulate the charge level of a battery.
  */
  int battery = analogRead(ADC_BATTERY);
  int batteryLevel = map(battery, 0, 1023, 0, 100);

  if (batteryLevel != oldBatteryLevel) {
    if (debug_mode) {                            // if the battery level has changed
      Serial.print("Battery Level % is now: ");  // print it
      Serial.println(batteryLevel);
    }

    characteristic.setValue((byte *)&batteryLevel, 12);
    oldBatteryLevel = batteryLevel;  // save the level for next comparison
  }
}