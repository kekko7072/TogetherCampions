void updateCompass(BLECharacteristic characteristic) {
  int x, y, z;  //triple axis data

  // Put the HMC5883 IC into the correct operating mode
  Wire.beginTransmission(0x1E);  //open communication with HMC5883
  Wire.write(0x02);              //select mode register
  Wire.write(0x00);              //continuous measurement mode
  Wire.endTransmission();

  Wire.beginTransmission(0x1E);
  Wire.write(0x03);  //select register 3, X MSB register
  Wire.endTransmission();

  //Read data from each axis, 2 registers per axis
  Wire.requestFrom(0x1E, 6);
  if (6 <= Wire.available()) {
    x = Wire.read() << 8;  //X msb
    x |= Wire.read();      //X lsb
    z = Wire.read() << 8;  //Z msb
    z |= Wire.read();      //Z lsb
    y = Wire.read() << 8;  //Y msb
    y |= Wire.read();      //Y lsb
  }

  //Print out values of each axis
  Serial.print("Magnetic compass: ");
  Serial.print("x: ");
  Serial.print(x);
  Serial.print("  y: ");
  Serial.print(y);
  Serial.print("  z: ");
  Serial.println(z);



  int eulers[3];
  eulers[0] = x;
  eulers[1] = y;
  eulers[2] = z;

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 12);
}