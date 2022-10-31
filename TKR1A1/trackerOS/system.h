#ifndef SYSTEM_H
#define SYSTEM_H

class SystemStatus {
private:
  BLECharacteristic characteristic;
  int timestamp;
  int batteryLevel;
  int16_t temperature;


public:
  SystemStatus(BLECharacteristic c);

  void update();
};

SystemStatus::SystemStatus(BLECharacteristic c) {
  characteristic = c;
}

void SystemStatus::update() {
  //Timestamp
  timestamp = millis();

  //Battery
  batteryLevel = map(analogRead(ADC_BATTERY), 713, 1023, 0, 100);

  //Temperature
 /* Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x41);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 8, true);           // request a total of 14 registers
  temperature = Wire.read() << 8 | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
  */
temperature = 0;
  int eulers[3] = { timestamp, batteryLevel, temperature };

  characteristic.setValue((byte *)&eulers, 12);
}

#endif