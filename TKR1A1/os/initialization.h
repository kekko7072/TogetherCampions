/* 
  GPRS initialization from SIM settings
*/
void initializationGPRS(GSM gsm, GPRS gprs) {
  bool connected = false;

  while (!connected) {
    if ((gsm.begin(SECRET_PINNUMBER) == GSM_READY) && (gprs.attachGPRS(SECRET_GPRS_APN, SECRET_GPRS_LOGIN, SECRET_GPRS_PASSWORD) == GPRS_READY)) {
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
int initializationSETTINGS(HttpClient http, int default_value) {

  StaticJsonDocument<64> doc_settings;
  int err = 0;
  int frequency = default_value;

  Serial.println("Initializing settings...");
  err = http.get(String(SERVER_SETTINGS) + String(SERIAL_NUMBER) + "&modelNumber=" + String(MODEL_NUMBER) + "&clock=" + String(CLOCK));
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
          frequency = doc_settings["frequency"];
        }

      } else if (err == 404) {
        Serial.println("Device " + String(SERIAL_NUMBER) + "not registered in app, please register it on the official app before powring on again");
        PinStatus pinStatus = HIGH;
        //Show led blinking forevere
        while (true) {
          digitalWrite(LED_BUILTIN, pinStatus);
          delay(500);
          pinStatus = pinStatus == HIGH ? LOW : HIGH;
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
  return frequency;
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