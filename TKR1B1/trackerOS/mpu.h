#ifndef MPU_H
#define MPU_H

#include "sdcard.h"
#include <MQTT.h>


void setupMPU() {
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0x5);   // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
}

char* outputStringAcc(int (&acc)[4]) {
  char output[50];
  sprintf(output, "MPU_ACCELERATION;%d;%d;%d;%d", acc[0], acc[1], acc[2], acc[3]);
  return output;
}

char* outputStringGyr(int (&gyr)[4]) {
  char* output = new char[50];
  sprintf(output, "MPU_GYROSCOPE;%d;%d;%d;%d", gyr[0], gyr[1], gyr[2], gyr[3]);
  return output;
}

void updateMPUAcceleration(int timestamp, MQTTClient client) {
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

  int acc[4];
  acc[0] = timestamp;
  acc[1] = AcX;
  acc[2] = AcY;
  acc[3] = AcZ;

  //Send using MQTT
  String topicPath = "/" + String(DEVICE_SERIAL_NUMBER) + "/MPU_ACCELERATION";
  client.publish(topicPath, outputStringAcc(acc));

  //Save on SDCARD
  sdcard_save(outputStringAcc(acc));
}

void updateMPUGyroscope(int timestamp, MQTTClient client) {
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

  int gyr[4];
  gyr[0] = timestamp;
  gyr[1] = GyX;
  gyr[2] = GyY;
  gyr[3] = GyZ;

  //Send using MQTT
  String topicPath = "/" + String(DEVICE_SERIAL_NUMBER) + "/MPU_GYROSCOPE";
  client.publish(topicPath, outputStringGyr(gyr));

  //Save on SDCARD
  sdcard_save(outputStringGyr(gyr));
}


#endif



// Try to initialize!
/* * <pre>
 *          |   ACCELEROMETER    |           GYROSCOPE
 * DLPF_CFG | Bandwidth | Delay  | Bandwidth | Delay  | Sample Rate
 * ---------+-----------+--------+-----------+--------+-------------
 * 0        | 260Hz     | 0ms    | 256Hz     | 0.98ms | 8kHz
 * 1        | 184Hz     | 2.0ms  | 188Hz     | 1.9ms  | 1kHz
 * 2        | 94Hz      | 3.0ms  | 98Hz      | 2.8ms  | 1kHz
 * 3        | 44Hz      | 4.9ms  | 42Hz      | 4.8ms  | 1kHz
 * 4        | 21Hz      | 8.5ms  | 20Hz      | 8.3ms  | 1kHz
 * 5        | 10Hz      | 13.8ms | 10Hz      | 13.4ms | 1kHz
 * 6        | 5Hz       | 19.0ms | 5Hz       | 18.6ms | 1kHz
 * 7        |   -- Reserved --   |   -- Reserved --   | Reserved
 * </pre>
 */


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