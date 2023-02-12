#ifndef SDCARD_H
#define SDCARD_H
/*
  Function to save data on SD CARD, returns:
    true: data saved successfully
    false: data not saved
*/

bool initializeSDCARD(int chipSelect) {
  Serial.print("Initializing SD card...");

  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return false;
  }
  Serial.println("card initialized.");
  return true;
}

void sdcard_save(String input_data) {

  // Open the file. Note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

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
    Serial.println("error opening datalog.txt");
  }
}

bool sdcard_clear() {
  SD.remove("datalog.txt");
  if (SD.exists("datalog.txt")) {
    Serial.println("error deleting datalog.txt");
    return false;
  } else {
    return true;
  }
}
#endif