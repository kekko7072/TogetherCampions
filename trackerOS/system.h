#ifndef SYSTEM_H
#define SYSTEM_H

#include "sdcard.h"


int getTemperature() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x41);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 8, true);  // request a total of 14 registers
  return Wire.read() << 8 | Wire.read();
}

String outputString(int (&sys)[3]) {
  return "SYSTEM;" + String(sys[0]) + ";" + String(sys[1]) + ";" + String(sys[2]);
}

#if DEVICE_MODEL == 0
#include <MQTT.h>

void updateSystem(int timestamp, MQTTClient client) {

  int sys[3];
  sys[0] = timestamp;
  sys[1] = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);
  sys[2] = getTemperature();

  //Send using MQTT
  String topicPath = "/" + String(DEVICE_SERIAL_NUMBER) + "/SYSTEM";
  client.publish(topicPath, outputString(sys));

  //Save on SDCARD
  sdcard_save(outputString(sys));
}

#else
#include <ArduinoBLE.h>

void updateSystem(int timestamp, BLECharacteristic characteristic) {

  int sys[3];
  sys[0] = timestamp;
  sys[1] = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);
  sys[2] = getTemperature();

  //Send using BLE
  characteristic.setValue((byte *)&sys, 12);

  //Save on SDCARD
  sdcard_save(outputString(sys));
}

#endif

#endif