void updateAcceleration(BLECharacteristic characteristic, int MPU) {
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true);               // request a total of 14 registers
  int16_t AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  int16_t AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  int16_t AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)


  Serial.print("Accelerometer: ");
  Serial.print("X = ");
  Serial.print(AcX);
  Serial.print(" | Y = ");
  Serial.print(AcY);
  Serial.print(" | Z = ");
  Serial.println(AcZ - 16384.0);  //AcZ - 16384.0 to make it inertail from the device position


  int eulers[3];
  eulers[0] = AcX;
  eulers[1] = AcY;
  eulers[2] = AcZ - 16384.0;

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 12);
}

void updateSpeed(int timePassed, BLECharacteristic characteristic, int MPU) {
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true);               // request a total of 14 registers
  int16_t AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  int16_t AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  int16_t AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)



  //Formula: g [m/s^2] * dT [s]
  float SpX = (AcX / 16384.0) * 9.81 * (timePassed * 0.001);              // AcX*dT
  float SpY = (AcY / 16384.0) * 9.81 * (timePassed * 0.001);              // AcY*dT
  float SpZ = ((AcZ - 16384.0) / 16384.0) * 9.81 * (timePassed * 0.001);  // (AcZ-16384.0)*dT to make it inertail from the device position



  Serial.print("Sped: ");
  Serial.print("X = ");
  Serial.print(SpX, 7);
  Serial.print(" | Y = ");
  Serial.print(SpY, 7);
  Serial.print(" | Z = ");
  Serial.println(SpZ, 7);


  float eulers[3];
  eulers[0] = SpX;
  eulers[1] = SpY;
  eulers[2] = SpZ;

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 12);
}

void updateTemperature(BLECharacteristic characteristic, int MPU) {
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true);               // request a total of 14 registers
  int16_t AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  int16_t AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  int16_t AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  int16_t Tmp = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)

  //equation for temperature in degrees C from datasheet
  float temperature = Tmp / 340.00 + 36.53;

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C ");


  characteristic.setValue((byte *)&temperature, 12);
}

void updateGyroscope(BLECharacteristic characteristic, int MPU) {
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 14, true);               // request a total of 14 registers
  int16_t AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  int16_t AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  int16_t AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  int16_t Tmp = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
  int16_t GyX = Wire.read() << 8 | Wire.read();  // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  int16_t GyY = Wire.read() << 8 | Wire.read();  // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  int16_t GyZ = Wire.read() << 8 | Wire.read();  // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)



  Serial.print("Gyroscope: ");
  Serial.print("X = ");
  Serial.print(GyX);
  Serial.print(" | Y = ");
  Serial.print(GyY);
  Serial.print(" | Z = ");
  Serial.println(GyZ);
  Serial.println(" ");
  //PITC pitch = 180 * atan2(accelX, sqrt(accelY*accelY + accelZ*accelZ))/PI;
  Serial.print("Pitch: ");
  Serial.print(atan2(AcX, sqrt(AcY * AcY + AcZ * AcZ)) * 57.3);
  //roll = 180 * atan2(accelY, sqrt(accelX*accelX + accelZ*accelZ))/PI
  Serial.print(" | Roll: ");
  Serial.print(atan2(AcY, AcZ) * 57.3);
  Serial.println(" ");


  int eulers[3];
  eulers[0] = AcX;
  eulers[1] = AcY;
  eulers[2] = AcZ;

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 12);

  //Save data on SDCARD
}