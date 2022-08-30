/*
  Function to save data on SD CARD, returns:
    true: data saved successfully
    false: data not saved
*/
bool sdcard_save(String input_data) {
  // Open the file. Note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

  //If the file is available, write to it:
  if (dataFile) {
    dataFile.print(input_data);
    dataFile.print("|"); //This caracter is used to end the clock cycle
    dataFile.close();
    return true;
  }

  // If the file isn't open, pop up an error:
  else {
    Serial.println("error opening datalog.txt");
    return false;
  }
}


/*
  Function to save data on SD CARD, returns:
    true: data saved successfully
    false: data not saved
*/
String sdcard_read() {
  //TODO replace String with something else because is creates memory leaks and bad working...
  String input_data = "";
  // Open the file. Note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

  if (dataFile) {
    // read from the file until there's nothing else in it:
    PinStatus ledStatus = HIGH;
    while (dataFile.available()) {
      Serial.print(".");
      Serial.write(dataFile.read());
      input_data = input_data + String(dataFile.read());
      digitalWrite(LED_BUILTIN, ledStatus);
      ledStatus = ledStatus == HIGH ? LOW : HIGH;
    }
    // close the file:
    dataFile.close();

    return input_data;
  }
  // If the file isn't open, pop up an error:
  else {
    Serial.println("error opening datalog.txt");
    return "";
  }
}