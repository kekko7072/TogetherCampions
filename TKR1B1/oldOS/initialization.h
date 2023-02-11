/* 
  LEDs initialization
*/
void initializationSWITCH() {
  Serial.print("Intializing  SWITCH:  ");
  pinMode(CLOUD_SDCARD, INPUT);
  Serial.print("OK");
  Serial.println();
}

/* 
  LEDs initialization
*/
void initializationLED() {
  Serial.print("Intializing  LEDs:  ");

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  Serial.print("OK");
  Serial.println();
}

/* 
  GPRS initialization from SIM settings
*/
void initializationGPRS(GSM gsm, GPRS gprs) {
  Serial.print("Intializing  GPRS:  ");
  bool connected = false;

  // After starting the modem with GSM.begin()
  // attach the shield to the GPRS network with the APN, login and password
  while (!connected) {
    if ((gsm.begin(SIM_PIN) == GSM_READY) && (gprs.attachGPRS(SIM_APN, SIM_LOGIN, SIM_PASSWORD) == GPRS_READY)) {
      connected = true;
      Serial.print("OK");
    } else {
      Serial.println("Not connected");
     
    }
  }
}


/* 
  GET settings from server
*/


/* 
  GPS using board periferials
*/


/* 
  SD CARD 
*/

