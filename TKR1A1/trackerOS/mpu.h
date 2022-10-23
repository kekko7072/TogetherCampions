void setupMPU() {
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
}

void updateAcceleration(BLECharacteristic characteristic, int timestamp) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);          // request a total of 14 registers
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


  int eulers[4];
  eulers[0] = AcX;
  eulers[1] = AcY;
  eulers[2] = AcZ;
  eulers[3] = millis();

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 16);
}

/*
void updateSpeed(int timePassed, BLECharacteristic characteristic) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);          // request a total of 14 registers
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
}*/

void updateTemperature(BLECharacteristic characteristic, int timestamp) {

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x41);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);                  // request a total of 14 registers
  int16_t temperature = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)

  //equation for temperature in degrees C from datasheet
  //float temperature = Tmp / 340.00 + 36.53;

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C ");

  int eulers[2];
  eulers[0] = temperature;
  eulers[1] = timestamp;

  characteristic.setValue((byte *)&eulers, 8);
}

void updateGyroscope(BLECharacteristic characteristic, int timestamp) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x43);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);  // request a total of 14 registers

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


  int eulers[4];
  eulers[0] = GyX;
  eulers[1] = GyY;
  eulers[2] = GyZ;
  eulers[3] = millis();

  // Send 3x eulers over bluetooth as 1x byte array
  characteristic.setValue((byte *)&eulers, 16);

  //Save data on SDCARD
}