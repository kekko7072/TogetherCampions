void tcaselect(uint8_t i2c_bus) {
  if (i2c_bus > 7) return;
  Wire.beginTransmission(MUX_ADDR);
  Wire.write(1 << i2c_bus);  //Bite shift to activate i2c port 00000001 . 00000010
  Wire.endTransmission();
}