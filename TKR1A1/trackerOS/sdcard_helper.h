bool sdcard_save(String input_data) {
  // Open the file. 
  //  note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("datalog.txt", FILE_WRITE);
  
  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(input_data);
    dataFile.close();
    return true;
  }
  
  // if the file isn't open, pop up an error:
  else {
    Serial.println("error opening datalog.txt");
    return false;
  }
}