/*
  This file is for the helpers of the code
*/

//Mode
enum Mode {
  unknown,
  cloud,
  sdCard
};

Mode mode_serializer(String value) {
  if (value == "Mode.cloud") {
    return cloud;
  } else if (value == "Mode.sdCard") {
    return sdCard;
  } else {
    return unknown;
  }
}

String mode_deserializer(Mode mode) {
  switch (settings.mode) {
        case cloud:
          return "Mode.cloud";
        case sdCard:
          return "Mode.sdCard";
      }
}

//Settings
struct Settings {
  Mode mode;
  int frequency;
};


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