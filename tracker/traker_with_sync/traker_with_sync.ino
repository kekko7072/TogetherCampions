#include <ArduinoHttpClient.h>
#include <MKRGSM.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoJson.h>
#include "arduino_secrets.h"


/*
  Set DEBUG_MODE to
    TRUE: When debugging with serial monitor
    FALSE: When launcing code for stand alone usage
*/
bool DEBUG_MODE = false;


/*
  You can programm the duration of CLOCK and the FREQUENCY:

    CLOCK: Is the time the code run in loop fetching data from GPS to SERVER in seconds [aproximatly]. 
      Ex. clock = 60  Means run for 60 seconds then data are send

    FREQUENCY: Is the time between each savings of data from GPS in seconds [aproximatly].
      Ex. frequency = 10  Means every 10 seconds new data are saved

  Remember to balance between CLOCK and FREQUENCY to optimize the code execuition.
*/
int clock = 3600;  
int frequency = 60;


/*
  The system use 128 byte for a single log. The max is 25000 bytes it means 195 logs.

  Calculate number of logs use this formula:
    N°logs = clock / frequency 

  Calculate bytes using tthis formula:
    Bytes = 128 * n°logs

  Replace bytes in StaticJsonDocument<BYTES> doc and remember to keep some margin (ex. for 7680 put 8000).
*/
StaticJsonDocument<8000> doc;
JsonArray array = doc.to<JsonArray>();


///***///


//SERVER https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
char server[] = "together-champions.ew.r.appspot.com";
char path[] = "/postData";
int port = 80;


//GSM
GSMClient gsmClient;
GPRS gprs;
GSM gsmAccess;
HttpClient client = HttpClient(gsmClient, server, port);

const char PINNUMBER[] = SECRET_PINNUMBER;
const char GPRS_APN[] = SECRET_GPRS_APN;
const char GPRS_LOGIN[] = SECRET_GPRS_LOGIN;
const char GPRS_PASSWORD[] = SECRET_GPRS_PASSWORD;


//DEVICE
char device_name[] = "Traker";
int clock_counter = 1;
int frequency_counter = 1;


///***///


void setup() {

  //COMUNICATION
  if (DEBUG_MODE) {
    Serial.begin(9600);
    while (!Serial) {
      ;  // wait for serial port to connect. Needed for native USB port only
    }
    Serial.println("Initialized " + String(device_name));
  }

  //GPRS
  bool connected = false;

  while (!connected) {
    if ((gsmAccess.begin(PINNUMBER) == GSM_READY) && (gprs.attachGPRS(GPRS_APN, GPRS_LOGIN, GPRS_PASSWORD) == GPRS_READY)) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(1000);
      digitalWrite(LED_BUILTIN, LOW);
      connected = true;
    } else {
      if (DEBUG_MODE) {
        Serial.println("Not connected");
        delay(1000);
      }
      digitalWrite(LED_BUILTIN, HIGH);
      delay(10000);
    }
  }

  //GPS
  if (!GPS.begin()) {
    if (DEBUG_MODE) {
      Serial.println("Failed to initialize GPS!");
    }
    while (1)
      ;
  }
}

void loop() {
  /* 

  NO HERE BECAUSE OUTSIIDE THE while (GPS.available()) LOOP 
  THE GPS WILL LOSE THE CONNECTION FROM THE SATELLITES 
  AND THEN TO RECONNECT IT WILL NEED 3/4 MINUTES

  */
  while (GPS.available()) {
    digitalWrite(LED_BUILTIN, HIGH);
    if (clock_counter <= clock) {
      if (DEBUG_MODE)
        Serial.println("Running cicle  " + String(clock_counter));


      if (frequency_counter == frequency) {
        if (DEBUG_MODE)
          Serial.println("Saving data at cicle  " + String(clock_counter));

        //SAVE DATA IN JSON OBJECT
        JsonObject nested = array.createNestedObject();
        nested["battery"] = analogRead(ADC_BATTERY) * (4.3 / 1023.0);
        nested["latitude"] = GPS.latitude();
        nested["longitude"] = GPS.longitude();
        nested["altitude"] = GPS.altitude();
        nested["speed"] = GPS.speed();
        nested["course"] = GPS.course();
        nested["satellites"] = GPS.satellites();

        if (DEBUG_MODE) {
          serializeJson(array, Serial);
          Serial.println();
        }

        //RESET FREQUENCY
        frequency_counter = 1;  //Reset frequency_counter
      }

      //INCREASE CLOCK AND FREQUENCY
      ++clock_counter;
      ++frequency_counter;
    } else {

      if (DEBUG_MODE) {
        Serial.println();
        Serial.println("Duration cicle: " + String(clock_counter) + " s");
        Serial.println("Memory used: " + String(array.memoryUsage()));
        Serial.println("Logs saved: " + String(array.size()));
        Serial.println();
      }

      //PREPARE DOCUMENTS TO SEND TO SERVER
      String contentType = "application/x-www-form-urlencoded";
      String inputJSON = "";
      serializeJson(array, inputJSON);
      String postData = "input={\"data\":" + inputJSON + "}&frequency=" + frequency + "&timestamp=" + String(gsmAccess.getTime());

      if (DEBUG_MODE) {
        Serial.println();
        Serial.println("making POST request");
        Serial.println(postData);
        Serial.println();
      }

      //POST DATA
      client.post("/postData?uid=RA207twfQF5LawcErH8j", contentType, postData);

      //READ RESPONSE
      int statusCode = client.responseStatusCode();
      String response = client.responseBody();

      if (DEBUG_MODE) {
        Serial.println();
        Serial.println("Status code: " + String(statusCode));
        Serial.println("Response: " + String(response));
        Serial.println();
      }

      if (statusCode == 200) {
        //RESET JSON AND COUNTER TO RESTART
        doc.clear();
        clock_counter = 1;
        frequency_counter = 1;

        digitalWrite(LED_BUILTIN, LOW);

      } else {        
        //TODO SAVE IT TO LOCAL STORAGE....
      }
    }
  }
}