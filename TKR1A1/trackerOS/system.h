void updateSystem(BLECharacteristic characteristic, int timestamp) {
  int batteryLevel = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x41);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);                  // request a total of 14 registers
  int16_t temperature = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)

  int eulers[3];
  eulers[0] = timestamp;
  eulers[1] = batteryLevel;
  eulers[2] = temperature;

  characteristic.setValue((byte *)&eulers, 12);
}