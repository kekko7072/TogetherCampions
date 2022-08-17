/*
  
  Operative System
  
  Model number: TKR1A1
  Version:  1.0.0 Beta
  Description:  This software is designed to solve all the relaiability problems given by the usage of JSON as object in traker_async_JSON.ino,
                as mentioned in this doc https://arduinojson.org/v6/issues/memory-leak/#why-does-this-happen so are replaced with arrays.

*/


#include <ArduinoHttpClient.h>
#include <MKRGSM.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoJson.h>
#include "configuration.h"
#include "helpers.h"
#include "initialization.h"


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
  Cellular module classes.
  NOTE: Cellular line works within 2 nautic miles from shore.
*/
GSM gsm;
GPRS gprs;
GSMClient gsmClient;


/*
  HTTP clients used as protocols to connect to the server.
*/
HttpClient http(gsmClient, SERVER_ADDRESS);


/*
  Runtime code executions variables, helping with counting functions and memorizing led status.
*/
int i = 0;
int err = 0;


void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);

  ///GPRS
  initializationGPRS(gsm, gprs);

  ///SETTINGS
  frequency = initializationSETTINGS(http, frequency);

  ///GPS
  initializationGPS();
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

      timestamp[i] = isnan(gsm.getTime());
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
      err = http.post(String(SERVER_POST) + String(SERIAL_NUMBER), content_type, post_data);
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