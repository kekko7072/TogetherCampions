#ifndef MPU_H
#define MPU_H

void setupMPU(Adafruit_MPU6050 mpu) {
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  // Try to initialize!
  /*if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);*/
}

void updateMPU(BLECharacteristic accelerometer, BLECharacteristic gyroscope) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);          // request a total of 14 registers
  int16_t AcX = Wire.read() << 8 | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  int16_t AcY = Wire.read() << 8 | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  int16_t AcZ = Wire.read() << 8 | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  int16_t temperature = Wire.read() << 8 | Wire.read();
  int16_t GyX = Wire.read() << 8 | Wire.read();  // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  int16_t GyY = Wire.read() << 8 | Wire.read();  // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  int16_t GyZ = Wire.read() << 8 | Wire.read();  // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)


  /*Serial.print(F("Accelerometer: X = "));
  Serial.print(AcX);
  Serial.print(F(" | Y = "));
  Serial.print(AcY);
  Serial.print(F(" | Z = "));
  Serial.println(AcZ);  //AcZ - 16384.0 to make it inertail from the device position
  Serial.print(F("Gyroscope: X = "));
  Serial.print(GyX);
  Serial.print(F(" | Y = "));
  Serial.print(GyY);
  Serial.print(" | Z = ");
  Serial.println(GyZ);
  Serial.println(F(" "));*/


  int acc[4];
  acc[0] = millis();
  acc[1] = AcX;
  acc[2] = AcY;
  acc[3] = AcZ;

  int gyr[4];
  acc[0] = millis();
  gyr[1] = GyX;
  gyr[2] = GyY;
  gyr[3] = GyZ;

  // Send x eulers over bluetooth as 1x byte array
  accelerometer.setValue((byte *)&acc, 16);
  gyroscope.setValue((byte *)&gyr, 16);
}

#endif