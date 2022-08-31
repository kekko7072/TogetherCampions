/*
  This file is for the helpers of the code
*/

//GPS value
/*
  Here are defined all the arrays used to store the datas.
*/
struct Input {
  int timestamp[DEVICE_CLOCK];
  float battery[DEVICE_CLOCK];
  float latitude[DEVICE_CLOCK];
  float longitude[DEVICE_CLOCK];
  float altitude[DEVICE_CLOCK];
  float speed[DEVICE_CLOCK];
  float course[DEVICE_CLOCK];
  int satellites[DEVICE_CLOCK];
};
/*
  Manual switch used to set if using SIM or OFFLINE
*/
//Status 
enum Status {
  online,
  offline
};

//Mode
enum Mode {
  realtime,
  record,
  sync
};

Mode mode_serializer(String value) {
  if (value == "Mode.realtime") {
    return realtime;
  } else if (value == "Mode.record") {
    return record;
  } else if (value == "Mode.sync") {
    return sync;
  }
}

String mode_deserializer(Mode mode) {
  switch (mode) {
    case realtime:
      return "Mode.realtime";
    case record:
      return "Mode.record";
    case sync:
      return "Mode.sync";
  }
}

//Settings
struct Settings {
  Status status;
  Mode mode;
  int frequency;
};


//Await some seconds
void await_seconds(int seconds) {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < seconds; i++) {
    Serial.print(".");
    digitalWrite(LED_BUILTIN, ledStatus);
    delay(1000);
    ledStatus = ledStatus == HIGH ? LOW : HIGH;
  }
}


//Available ram memory https://docs.arduino.cc/learn/programming/memory-guide#flash-memory-measurement
extern "C" char* sbrk(int incr);

int freeRam() {
  char top;
  return &top - reinterpret_cast<char*>(sbrk(0));
}
void display_freeram() {
  Serial.print(F("- SRAM left: "));
  Serial.println(freeRam());
}