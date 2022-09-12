#include <MKRGSM.h>
#include <ArduinoHttpClient.h>
#include <SPI.h>
#include <SD.h>
#include <Arduino_MKRGPS.h>
#include <ArduinoJson.h>
#include "configuration.h"
#include "general_helper.h"
#include "cloud_helper.h"
#include "sdcard_helper.h"
#include "initialization.h"



/*
  Settings is the enum of parameters used as settings.
*/
Settings settings;


/*
  Here are defined all the arrays used to store the datas.
*/
Input input;


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
const HttpClient http(gsmClient, SERVER_ADDRESS);

/*
  SD CARD chip protocol
*/
const int chipSelect = 4;


/*
  LEDs state saver, each colors means something:
    GREEN: Saving data on the cloud.
    YELLOW: Saving data on the SD CARD.
    RED: Errors, GPS not connecting.

*/
PinStatus ledGREEN = HIGH;
PinStatus ledYELLOW = HIGH;
PinStatus ledRED = HIGH;


/*
  Runtime code executions variables, helping with counting functions and memorizing led status.
*/
int i = 0;
int err = 0;


void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);

  ///ONLY FOR DEBUG
  /*
  while (!Serial) {
    ;  // wait for serial port to connect. Needed for native USB port only
  }
  Serial.println("Initialing device...");
  Serial.println();
  */
  ///

  initialize();
}

void loop() {
  /* 
    COMUNICATION USING SERIAL FOR OPERATION LIKE CONNECTING AND SDCARD STATUS.
  */
  if (Serial.available() > 0) {
    // read the incoming byte:
    String input = Serial.readString();  //read until timeout
    input.trim();
    Serial.println(input);
    if (input == "DEVICE_INFO") {
      Serial.println(DEVICE_MODEL_NUMBER);
      Serial.println(DEVICE_SERIAL_NUMBER);
    } else if (input == "STATUS_SDCARD") {
      sdcard_status();
    } else if (input == "READ_SDCARD") {
      //bool success = sdcard_read();
      sdcard_read();
      // Serial.println(sdcard_read());
      //Serial.println("Operation completed: " + success == 0 ? "TRUE" : "FALSE");
    } else if (input == "CLEAR_SDCARD") {
      bool success = sdcard_clear();
      Serial.println("Operation completed: " + success ? "TRUE" : "FALSE");
    }
  }
  /* 
    NO CODE HERE BECAUSE IF YOU PUT LOGIC HERE, OUTSIIDE THE while(GPS.available()) LOOP,
    THE GPS WILL LOSE THE CONNECTION FROM THE SATELLITES 
    AND THEN TO RECONNECT IT WILL NEED 3/4 MINUTES EACH TIMES.
  */
  while (GPS.available()) {

    //TURN OFF GPS AND STATUS LED
    gps_connected(settings.status);

    if (i < DEVICE_CLOCK) {

      //AWAIT SYNC FROM FREQUENCY
      await_with_blinking(settings.frequency, settings.status);

      //SAVE DATA INTO ARRAYS
      turn_status_LED(settings.status, HIGH);
      Serial.println();
      Serial.println("Saving data at cicle  " + String(i));

      input.timestamp[i] = settings.status == cloud ? gsm.getTime() : millis();
      input.battery[i] = analogRead(ADC_BATTERY) * (4.3 / 1023.0);
      input.latitude[i] = isnan(GPS.latitude()) ? 0.0 : GPS.latitude();
      input.longitude[i] = isnan(GPS.longitude()) ? 0.0 : GPS.longitude();
      input.altitude[i] = isnan(GPS.altitude()) ? 0.0 : GPS.altitude();
      input.speed[i] = isnan(GPS.speed()) ? 0.0 : GPS.speed();
      input.course[i] = isnan(GPS.course()) ? 0.0 : GPS.course();
      input.satellites[i] = isnan(GPS.satellites()) ? 0.0 : GPS.satellites();

      i++;
    } else {

      Serial.println();
      Serial.println("Duration cicle: " + String(i * settings.frequency) + " s");
      Serial.println("Logs saved: " + String(i));
      Serial.println();

      String input_data = "clock=" + String(DEVICE_CLOCK) + "&frequency=" + String(settings.frequency);
      for (int k = 0; k < i; k++) {
        input_data = input_data + "&timestamp=" + String(input.timestamp[k]) + "&battery=" + String(input.battery[k])
                     + "&latitude=" + String(input.latitude[k], 7) + "&longitude=" + String(input.longitude[k], 7)
                     + "&altitude=" + String(input.altitude[k], 7) + "&speed=" + String(input.speed[k], 7) + "&course="
                     + String(input.course[k], 7) + "&satellites=" + String(input.satellites[k]);
      }

      Serial.println(input_data);
      display_freeram();

      switch (settings.status) {
        case cloud:
          {
            if (cloud_save(http, settings, input_data)) {
              turn_status_LED(settings.status, LOW);

              i = 0;
              input_data = "";
            } else {
              Serial.print("Cloud save returned false");
              await_with_blinking_error(5);
            }
            break;
          }
        case sdCard:
          {
            if (sdcard_save(input_data)) {
              turn_status_LED(settings.status, LOW);
              i = 0;
              input_data = "";
            } else {
              Serial.print("SD card helper returned false");
              await_with_blinking_error(5);
            }
            break;
          }
      }
    }
  }
}

void initialize() {

  //SWITCH
  initializationSWITCH();

  //LED
  initializationLED();

  settings.status = status_reader(digitalRead(CLOUD_SDCARD));
  turn_status_LED(settings.status, HIGH);

  if (settings.status == cloud) {
    ///GPRS
    initializationGPRS(gsm, gprs);

    //SD CARD
    bool sdCard_available = initializationSDCARD(chipSelect);

    ///SETTINGS
    settings = initializationSETTINGS(http, sdCard_available);
  } else {

    settings.status == sdCard;
    // settings.mode = record;
    settings.frequency = 10;
    //SD CARD
    bool sdCard_available = initializationSDCARD(chipSelect);
    Serial.print(sdCard_available == 0 ? "FALSE" : "TRUE");
  }

  ///GPS
  initializationGPS();

}