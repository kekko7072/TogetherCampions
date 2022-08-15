#include <ArduinoHttpClient.h>
#include <MKRGSM.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoJson.h>
#include "arduino_secrets.h"


/*
  Set a device_id unique for every new device released
  should be a string
*/
String device_id = "RA207twQF5LawcErH8j";


/*
  Set DEBUG_MODE to
    TRUE: When debugging with serial monitor
    FALSE: When launcing code for stand alone usage
*/
bool DEBUG_MODE = true;


/*
  You can programm the duration of CLOCK and the FREQUENCY:

    CLOCK: Is the time the code run in loop fetching data from GPS to SERVER [aproximatly]. 
      Ex. clock = 60  Means run 60 times then data are send

    FREQUENCY: Is the time between each savings of data from GPS in seconds [aproximatly].
      Ex. frequency = 10  Means run 1 clock every 10 seconds

  Remember to balance between CLOCK and FREQUENCY to optimize the code execuition.
  Ideal for debugging is CLOCK = 6 and FREQUENCY = 10 .
  Calculate time of code:
    Time of execution = clock * frequency;  
*/
int clock = 6;
int frequency = 10;


/*
  The system use 144 byte for a single log. The max is 2200 bytes it means 152 logs.

  Calculate number of logs use this formula:
    N°logs = clock 

  Calculate bytes using tthis formula:
    Bytes = 144 * n°logs

  Replace bytes in StaticJsonDocument<BYTES> doc and remember to keep some margin (ex. for 6640 put 9000).
*/
StaticJsonDocument<2200> doc;
JsonArray array = doc.to<JsonArray>();

StaticJsonDocument<64> doc_settings;

///TODO STORAGE https://github.com/cmaglie/FlashStorage

///***///


//SERVER https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
char server[] = "together-champions.ew.r.appspot.com";
String path_settings = "/settings?id=";
String path_post = "/post?id=";
int port = 80;


//GSM
GSMClient gsmClient;
GPRS gprs;
GSM gsmAccess;
HttpClient client = HttpClient(gsmClient, server, port);
HttpClient http(gsmClient, server);


const char PINNUMBER[] = SECRET_PINNUMBER;
const char GPRS_APN[] = SECRET_GPRS_APN;
const char GPRS_LOGIN[] = SECRET_GPRS_LOGIN;
const char GPRS_PASSWORD[] = SECRET_GPRS_PASSWORD;


//HELPERS
int clock_counter = 1;
PinStatus ledStatus = HIGH;
int err = 0;

///***///


void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for native USB port only
  }

  bool connected = false;

  while (!connected) {
    if ((gsmAccess.begin(PINNUMBER) == GSM_READY) && (gprs.attachGPRS(GPRS_APN, GPRS_LOGIN, GPRS_PASSWORD) == GPRS_READY)) {
      connected = true;
    } else {

      Serial.println("Not connected");
      delay(1000);

      int duration = 0;
      while (duration <= 100) {
        digitalWrite(LED_BUILTIN, HIGH);
        delay(100);
        digitalWrite(LED_BUILTIN, LOW);
        ++duration;
      }
    }
    Serial.println("connected");
  }

  ///LOAD SETTINGS
  Serial.println("Initializing settings...");
  err = http.get(path_settings + String(device_id));
  if (err == 0) {
    Serial.println("startedRequest ok");

    err = http.responseStatusCode();
    if (err >= 0) {

      String response = http.responseBody();
      Serial.println();
      Serial.println("Status code: " + String(err));
      Serial.println("Response: " + String(response));
      Serial.println();

      DeserializationError error = deserializeJson(doc_settings, response);

      if (error) {
        Serial.print("deserializeJson() failed: ");
        Serial.println(error.c_str());
        return;
      }
      clock = doc_settings["clock"];
      frequency = doc_settings["frequency"];

      Serial.println("  clock:  " + String(clock));
      Serial.println("  frequency:  " + String(frequency));

    } else {
      Serial.print("Getting response failed: ");
      Serial.println(err);
    }
  } else {
    Serial.print("Connect failed: ");
    Serial.println(err);
  }
  http.stop();
  ///

  ///GPS
  Serial.println();
  Serial.print("Intializing  GPS:  ");

  if (!GPS.begin()) {
    if (DEBUG_MODE) {
      Serial.println("Failed to initialize GPS!");
    }
    while (1)
      ;
  }
  if (DEBUG_MODE) {
    Serial.print("OK");
  }
  ///
}

void loop() {
  /* 

  NO CODE HERE BECAUSE IF YOU PUT LOGIC HERE, OUTSIIDE THE while (GPS.available()) LOOP,
  THE GPS WILL LOSE THE CONNECTION FROM THE SATELLITES 
  AND THEN TO RECONNECT IT WILL NEED 3/4 MINUTES

  */
  while (GPS.available()) {
    if (clock_counter <= clock) {

      digitalWrite(LED_BUILTIN, LOW);

      //AWAIT SYNC FROM FREQUENCY
      for (int i = 0; i < frequency; i++) {

        Serial.print(".");

        digitalWrite(LED_BUILTIN, ledStatus);
        delay(1000);
        ledStatus = ledStatus == HIGH ? LOW : HIGH;
      }

      digitalWrite(LED_BUILTIN, HIGH);

      Serial.println();
      Serial.println("Saving data at cicle  " + String(clock_counter));

      //SAVE DATA INTO JSON OBJECT
      JsonObject nested = array.createNestedObject();
      nested["timestamp"] = gsmAccess.getTime();
      nested["battery"] = analogRead(ADC_BATTERY) * (4.3 / 1023.0);
      nested["latitude"] = GPS.latitude();
      nested["longitude"] = GPS.longitude();
      nested["altitude"] = GPS.altitude();
      nested["speed"] = GPS.speed();
      nested["course"] = GPS.course();
      nested["satellites"] = GPS.satellites();

      serializeJson(array, Serial);
      Serial.println();

      //INCREASE CLOCK
      ++clock_counter;
    } else {

      Serial.println();
      Serial.println("Duration cicle: " + String(clock_counter * frequency) + " s");
      Serial.println("Memory used: " + String(array.memoryUsage()));
      Serial.println("Logs saved: " + String(array.size()));
      Serial.println();

      //PREPARE DATA TO SEND TO SERVER
      String contentType = "application/x-www-form-urlencoded";
      String inputJSON = "";
      serializeJson(array, inputJSON);
      String postData = "input={\"data\":" + inputJSON + "}&frequency=" + frequency;

      Serial.println();
      Serial.println("making POST request");
      Serial.println(postData);
      Serial.println();

      //POST DATA
      client.post(path_post + String(device_id), contentType, postData);
      //TODO MANAGE TO SEND ALSO THE SAVED DATA IF NEEDED TO UPLOAD AGAIN

      //READ RESPONSE
      int statusCode = client.responseStatusCode();
      String response = client.responseBody();

      Serial.println();
      Serial.println("Status code: " + String(statusCode));
      Serial.println("Response: " + String(response));
      Serial.println();

      if (statusCode == 200) {
        //RESET JSON AND COUNTER TO RESTART
        doc.clear();
        clock_counter = 1;

      } else {

        //LOPING TO SHOW ERROR
        ledStatus = HIGH;
        for (int i = 0; i < 10; i++) {

          Serial.print(".");

          digitalWrite(LED_BUILTIN, ledStatus);
          delay(1000);
          ledStatus = ledStatus == HIGH ? LOW : HIGH;
        }
      }
    }
  }
}