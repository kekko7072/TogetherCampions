void updateBatteryLevel(BLECharacteristic characteristic) {
  /* Read the current voltage level on the A0 analog input pin.
     This is used here to simulate the charge level of a battery.
  */
  
  int batteryLevel = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);

  int eulers[2];
  eulers[0] = batteryLevel;
  eulers[1] = millis();

  // if (batteryLevel != oldBatteryLevel) {
  // if the battery level has changed
  Serial.print("Battery Level % is now: ");  // print it
  Serial.println(batteryLevel);


  characteristic.setValue((byte *)&batteryLevel, 8);
  //oldBatteryLevel = batteryLevel;  // save the level for next comparison
  //  }
}