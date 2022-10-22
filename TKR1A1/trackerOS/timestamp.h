

void updateTimestamp(BLECharacteristic characteristic) {
  /* 
    Read the current timestamp
  */
  int timestamp = millis();

  characteristic.setValue((byte *)&timestamp, 4);
}