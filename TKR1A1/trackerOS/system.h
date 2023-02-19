#ifndef SYSTEM_H
#define SYSTEM_H

#include "sdcard.h"

void updateSystem(int timestamp, BLECharacteristic characteristic) {

  //Temperature
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x41);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 8, true);  // request a total of 14 registers
  int16_t temperature = Wire.read() << 8 | Wire.read();

  int sys[3];
  sys[0] = timestamp;
  sys[1] = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);
  sys[2] = temperature;

  //Send using BLE
  characteristic.setValue((byte *)&sys, 12);
  
  //Save on SDCARD
  String data = "SYSTEM;" + String(sys[0]) + ";" + String(sys[1]) + ";" + String(sys[2]);
  sdcard_save(data);
}

#endif