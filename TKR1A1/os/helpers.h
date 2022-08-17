/*
  This file is for the helpers of the code
*/

//Await some seconds
void await_seconds(int frequency) {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < frequency; i++) {
    Serial.print(".");
    digitalWrite(LED_BUILTIN, ledStatus);
    delay(1000);
    ledStatus = ledStatus == HIGH ? LOW : HIGH;
  }
}

//Print available ram memory https://docs.arduino.cc/learn/programming/memory-guide#flash-memory-measurement
extern "C" char* sbrk(int incr);

int freeRam() {
  char top;
  return &top - reinterpret_cast<char*>(sbrk(0));
}
void display_freeram() {
  Serial.print(F("- SRAM left: "));
  Serial.println(freeRam());
}