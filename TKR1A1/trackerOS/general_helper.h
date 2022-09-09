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
  cloud,
  sdCard
};

Status status_reader(int buttonState) {
  if (buttonState) {
    return cloud;
  } else {
    return sdCard;
  }
}

/*
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
}*/

//Settings
struct Settings {
  Status status;
  int frequency;
};

/*
  This file is for the helpers of the code
*/
//LED helper
void turn_off_all_LED() {
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
}

void turn_status_LED(Status settings, PinStatus pinStatus) {
  if (settings == cloud) {
    digitalWrite(LED_GREEN, pinStatus);
  } else if (settings == sdCard) {
    digitalWrite(LED_YELLOW, pinStatus);
  }
}

void turn_error_LED(PinStatus pinStatus) {
  digitalWrite(LED_RED, pinStatus);
}

//Await some seconds
void await_with_blinking(int seconds, Status settings) {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < seconds; i++) {
    Serial.print(".");
    turn_status_LED(settings, ledStatus);
    delay(1000);
    ledStatus = ledStatus == HIGH ? LOW : HIGH;
  }
}

void await_with_blinking_error(int seconds) {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < seconds; i++) {
    Serial.print(".");
    turn_error_LED(ledStatus);
    delay(1000);
    ledStatus = ledStatus == HIGH ? LOW : HIGH;
  }
}

void led_battery_charging() {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < 5; i++) {
    delay(500);
    digitalWrite(LED_GREEN, HIGH);
    delay(500);
    digitalWrite(LED_YELLOW, HIGH);
    delay(500);
    digitalWrite(LED_RED, HIGH);
    delay(500);
    digitalWrite(LED_RED, LOW);
    delay(500);
    digitalWrite(LED_YELLOW, LOW);
    delay(500);
    digitalWrite(LED_GREEN, LOW);
  }
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_GREEN, LOW);
}

void led_battery_low() {
  PinStatus ledStatus = HIGH;
  for (int i = 0; i < 10; i++) {
    digitalWrite(LED_YELLOW, ledStatus);
    digitalWrite(LED_RED, ledStatus);
    ledStatus = ledStatus == HIGH ? LOW : HIGH;
    delay(500);
  }
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_GREEN, LOW);
}

//GPS blink
void gps_connecting(Status settings) {
  turn_status_LED(settings, HIGH);
  digitalWrite(LED_RED, HIGH);
}
void gps_connected(Status settings) {
  turn_status_LED(settings, LOW);
  digitalWrite(LED_RED, LOW);
}

//SWITCH READER AND CONVERTER

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