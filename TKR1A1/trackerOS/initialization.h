/* 
  GPRS initialization from SIM settings
*/
void initializationGPRS(GSM gsm, GPRS gprs) {
  bool connected = false;

  while (!connected) {
    if ((gsm.begin(SIM_PIN) == GSM_READY) && (gprs.attachGPRS(SIM_APN, SIM_LOGIN, SIM_PASSWORD) == GPRS_READY)) {
      connected = true;
    } else {

      Serial.println("Not connected");

      await_seconds(10);
    }
    Serial.println("Connected");
  }
}


/* 
  GET settings from server
*/
struct Settings initializationSETTINGS(HttpClient http, bool sdCard_available) {

  StaticJsonDocument<64> doc_settings;
  int err = 0;
  struct Settings set;

  //Set default value
  set.mode = cloud;
  set.frequency = 10;

  Serial.println("Initializing settings...");
  String sdCardAvailable = sdCard_available ? "true" : "false";
  err = http.get(String(SERVER_SETTINGS) + String(DEVICE_SERIAL_NUMBER) + "&modelNumber=" + String(DEVICE_MODEL_NUMBER)
                 + "&clock=" + String(DEVICE_CLOCK) + "&sdCardAvailable=" + sdCardAvailable + "&softwareName=" + String(SOFTWARE_NAME)
                 + "&softwareVersion=" + String(SOFTWARE_VERSION));
  if (err == 0) {
    Serial.println("Started GET ok");

    err = http.responseStatusCode();
    if (err >= 0) {

      String response = http.responseBody();
      Serial.println("Status code: " + String(err));
      Serial.println("Response: " + String(response));

      if (err == 200) {
        DeserializationError error = deserializeJson(doc_settings, response);

        if (error) {
          Serial.print("deserializeJson() failed: ");
          Serial.println(error.c_str());
        } else {
          set.mode = mode_serializer(doc_settings["mode"]);
          set.frequency = doc_settings["frequency"];
        }

      } else if (err == 404) {
        Serial.println("Device " + String(DEVICE_SERIAL_NUMBER) + " not registered, registering first time now.");

        if (!cloud_register_device(http, set, sdCard_available)) {
          PinStatus pinStatus = HIGH;
          //Show led blinking forevere
          while (true) {
            digitalWrite(LED_BUILTIN, pinStatus);
            delay(500);
            pinStatus = pinStatus == HIGH ? LOW : HIGH;
          }
        }
      }
    } else {
      Serial.print("Getting response failed: " + String(err));
    }
  } else {
    Serial.print("Connect failed: ");
    Serial.println(err);
  }
  doc_settings.clear();
  http.stop();
  return set;
}

/* 
  GPS using board periferials
*/
void initializationGPS() {
  Serial.println();
  Serial.print("Intializing  GPS:  ");

  if (!GPS.begin()) {
    Serial.println("Failed to initialize GPS!");
    while (1)
      ;
  }
  Serial.print("OK");
  Serial.println();
}

/* 
  SD CARD 
*/

bool initializationSDCARD(int chipSelect) {
  Serial.print("Intializing  SD CARD:  ");

  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    return false;
  } else {
    Serial.print("OK");
    Serial.println();
    return true;
  }
}