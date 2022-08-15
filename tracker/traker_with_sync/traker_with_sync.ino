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
int clock = 60;
int frequency = 10;


/*
  The system use 144 byte for a single log. The max is 25000 bytes it means 173 logs.

  Calculate number of logs use this formula:
    N°logs = clock 

  Calculate bytes using tthis formula:
    Bytes = 144 * n°logs

  Replace bytes in StaticJsonDocument<BYTES> doc and remember to keep some margin (ex. for 6640 put 9000).
*/
StaticJsonDocument<8000> doc;
JsonArray array = doc.to<JsonArray>();

///TODO STORAGE https://github.com/cmaglie/FlashStorage
/*FlashStorage(data_storage, String);*/

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
PinStatus ledStatus = HIGH;


///***///


void setup() {

  //COMUNICATION
  Serial.begin(9600);
  if (DEBUG_MODE) {
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
      int duration = 0;
      while (duration <= 100) {
        digitalWrite(LED_BUILTIN, HIGH);
        delay(100);
        digitalWrite(LED_BUILTIN, LOW);
        ++duration;
      }
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

  NO CODE HERE BECAUSE IF YOU PUT LOGIC HERE, OUTSIIDE THE while (GPS.available()) LOOP,
  THE GPS WILL LOSE THE CONNECTION FROM THE SATELLITES 
  AND THEN TO RECONNECT IT WILL NEED 3/4 MINUTES

  */
  while (GPS.available()) {
    if (clock_counter <= clock) {

      digitalWrite(LED_BUILTIN, LOW);

      //AWAIT SYNC FROM FREQUENCY
      for (int i = 0; i < frequency; i++) {
        if (DEBUG_MODE) {
          Serial.print(".");
        }

        digitalWrite(LED_BUILTIN, ledStatus);
        delay(1000);
        ledStatus = ledStatus == HIGH ? LOW : HIGH;
      }

      digitalWrite(LED_BUILTIN, HIGH);

      if (DEBUG_MODE) {
        Serial.println();
        Serial.println("Saving data at cicle  " + String(clock_counter));
      }

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

      if (DEBUG_MODE) {
        serializeJson(array, Serial);
        Serial.println();
      }

      //INCREASE CLOCK
      ++clock_counter;
    } else {

      if (DEBUG_MODE) {
        Serial.println();
        Serial.println("Duration cicle: " + String(clock_counter * frequency) + " s");
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
      //TODO MANAGE TO SEND ALSO THE SAVED DATA IF NEEDED TO UPLOAD AGAIN

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

      } else {
        //TODO SAVE IT TO LOCAL STORAGE....
        /*data_storage.write(postData);*/
      }
    }
  }
}