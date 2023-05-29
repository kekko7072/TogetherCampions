#ifndef SDCARD_H
#define SDCARD_H
/*
  Function to save data on SD CARD, returns:
    true: data saved successfully
    false: data not saved
*/

void sdcard_save(String input_data) {

  // Open the file. Note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("DATALOG.txt", FILE_WRITE);

  //TODO manage the scenareo where sdcard is full
  //if system online report to app
  //if system offline start blinking device

  //If the file is available, write to it:
  if (dataFile) {
    dataFile.print(input_data);
    dataFile.print(",");  //This caracter is used to end the clock cycle
    dataFile.close();
  }

  // If the file isn't open, pop up an error:
  else {
    Serial.println("error opening DATALOG.txt");
  }
}

bool sdcard_clear() {
  SD.remove("datalog.txt");
  if (SD.exists("datalog.txt")) {
    Serial.println("SDCARD error deleting DATALOG.txt");
    return false;
  } else {
    Serial.println("SDCARD initialized.");
    return true;
  }
}

bool initializeSDCARD(int chipSelect) {
  Serial.print("Initializing SD card...");

  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("SDCARD failed, or not present");
    // don't do anything more:
    return false;
  }
  return sdcard_clear();
}
#endif