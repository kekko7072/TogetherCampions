/*
  
  Tracker Operative System - TOS
  
  Device: ARDUINO MKR 1400 GSM + GPS MODULE
  Version:  1.0.0 BETA
  Description:  This software is designed to solve all the relaiability problems given by the usage of JSON as object,
                as mentioned here[https://arduinojson.org/v6/issues/memory-leak/#why-does-this-happen] so replace it with arrays.

*/

#include <ArduinoHttpClient.h>
#include <MKRGSM.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoJson.h>
#include "configuration.h"
#include "helpers.h"

/*
  Set a new device_id unique for every new device released using https://www.uuidgenerator.net/version1 .
  The device_id should be printed and given to the user to configure the device for his account.
*/
String device_id = "RA207twQF5LawcErH8j";


/*
  FREQUENCY: Is the time between each savings of data from GPS in seconds [aproximatly].
    Ex. frequency = 10  Means run 1 clock every 10 seconds
*/
int frequency = 10;


/*
  Here are defined all the arrays used to store the datas.
*/
int timestamp[CLOCK];
float battery[CLOCK];
float latitude[CLOCK];
float longitude[CLOCK];
float altitude[CLOCK];
float speed[CLOCK];
float course[CLOCK];
int satellites[CLOCK];


/*
  This is the document to deserialize the JSON file to given by the device settings.
*/
StaticJsonDocument<64> doc_settings;

/*
  Cellular module classes.
  NOTE: Cellular line works within 2 nautic miles from shore.
*/
GSMClient gsmClient;
GPRS gprs;
GSM gsmAccess;


/*
  Server are used to store data on the cloud.
  Link to dashboard: https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
*/
char server[] = "together-champions.ew.r.appspot.com";
String path_settings = "/settings?id=";
String path_post = "/post?id=";
int port = 80;


/*
  HTTP clients used as protocols to connect to the server.
*/
//HttpClient client = HttpClient(gsmClient, server, port);
HttpClient http(gsmClient, server);


/*
  Runtime code executions variables, helping with counting functions and memorizing led status.
*/
int i = 0;
int err = 0;


void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);

  bool connected = false;

  while (!connected) {
    if ((gsmAccess.begin(SECRET_PINNUMBER) == GSM_READY) && (gprs.attachGPRS(SECRET_GPRS_APN, SECRET_GPRS_LOGIN, SECRET_GPRS_PASSWORD) == GPRS_READY)) {
      connected = true;
    } else {

      Serial.println("Not connected");
      
      await_seconds(10);
    }
    Serial.println("Connected");
  }

  ///LOAD SETTINGS
  Serial.println("Initializing settings...");
  err = http.get(path_settings + String(device_id));
  if (err == 0) {
    Serial.println("Started GET ok");

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
      frequency = doc_settings["frequency"];

    } else {
      Serial.print("Getting response failed: " + String(err));
    }
  } else {
    Serial.print("Connect failed: ");
    Serial.println(err);
  }
  doc_settings.clear();
  http.stop();
  ///

  ///GPS
  Serial.println();
  Serial.print("Intializing  GPS:  ");

  if (!GPS.begin()) {
    Serial.println("Failed to initialize GPS!");
    while (1)
      ;
  }
  Serial.print("OK");
  Serial.println();
  ///
}

void loop() {
  /* 

  NO CODE HERE BECAUSE IF YOU PUT LOGIC HERE, OUTSIIDE THE while (GPS.available()) LOOP,
  THE GPS WILL LOSE THE CONNECTION FROM THE SATELLITES 
  AND THEN TO RECONNECT IT WILL NEED 3/4 MINUTES

  */
  while (GPS.available()) {

    if (i < CLOCK) {
      digitalWrite(LED_BUILTIN, LOW);

      //AWAIT SYNC FROM FREQUENCY
      await_seconds(frequency);

      //SAVE DATA INTO ARRAYS
      digitalWrite(LED_BUILTIN, HIGH);
      Serial.println();
      Serial.println("Saving data at cicle  " + String(i));

      timestamp[i] = isnan(gsmAccess.getTime());
      battery[i] = analogRead(ADC_BATTERY) * (4.3 / 1023.0);
      latitude[i] = isnan(GPS.latitude()) ? 0.0 : GPS.latitude();
      longitude[i] = isnan(GPS.longitude()) ? 0.0 : GPS.longitude();
      altitude[i] = isnan(GPS.altitude()) ? 0.0 : GPS.altitude();
      speed[i] = isnan(GPS.speed()) ? 0.0 : GPS.speed();
      course[i] = isnan(GPS.course()) ? 0.0 : GPS.course();
      satellites[i] = isnan(GPS.satellites()) ? 0.0 : GPS.satellites();

      i++;
    } else {

      Serial.println();
      Serial.println("Duration cicle: " + String(CLOCK * frequency) + " s");
      Serial.println("Logs saved: " + String(CLOCK));
      Serial.println();

      String input_data;
      for (int k = 0; k < CLOCK; k++) {
        input_data = input_data + "&timestamp=" + String(timestamp[k]) + "&battery=" + String(battery[k]) + "&latitude=" + String(latitude[k], 7) + "&longitude=" + String(longitude[k], 7) + "&altitude=" + String(altitude[k], 7) + "&speed=" + String(speed[k], 7) + "&course=" + String(course[k], 7) + "&satellites=" + String(satellites[k]);
      }
      Serial.println(input_data);
      display_freeram();

      //PREPARE DATA TO SEND TO SERVER
      char content_type[] = "application/x-www-form-urlencoded";
      String post_data = "clock=" + String(CLOCK) + "&frequency=" + String(frequency) + input_data;

      Serial.println();
      Serial.println("Making POST request");
      Serial.println(post_data);
      Serial.println();

      //POST DATA
      err = http.post(path_post + String(device_id), content_type, post_data);
      if (err == 0) {
        Serial.println("Started POST ok");
        //READ RESPONSE
        int status_code = http.responseStatusCode();
        String response = http.responseBody();

        Serial.println();
        Serial.println("Status code: " + String(status_code));
        Serial.println("Response: " + String(response));
        Serial.println();

        if (status_code == 200) {
          Serial.println("Data send sucessfully");
          i = 0;
          input_data = "";
        } else {
          Serial.println("Getting response failed: " + String(err));
        }

      } else {
        Serial.println("Connect failed: " + String(err));
        await_seconds(10);
      }
      http.stop();
    }
  }
}