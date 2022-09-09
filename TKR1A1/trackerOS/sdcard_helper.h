/*
  Function to save data on SD CARD, returns:
    true: data saved successfully
    false: data not saved
*/
bool sdcard_save(String input_data) {

  // Open the file. Note that only one file can be open at a time,  so you have to close this one before opening another.
  File dataFile = SD.open("DATALOG.TXT", FILE_WRITE);

  //TODO manage the scenareo where sdcard is full
  //if system online report to app
  //if system offline start blinking device

  //If the file is available, write to it:
  if (dataFile) {
    dataFile.print(input_data);
    dataFile.print(",");  //This caracter is used to end the clock cycle
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
  File dataFile = SD.open("DATALOG.TXT", FILE_WRITE);

  if (dataFile) {
    // read from the file until there's nothing else in it:
    while (dataFile.available()) {
      Serial.write(dataFile.read());
      input_data = input_data + String(dataFile.read());
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
bool sdcard_status() {
  /*

  SD card test

  This example shows how use the utility libraries on which the'

  SD library is based in order to get info about your SD card.

  Very useful for testing a card when you're not sure whether its working or not.

  Pin numbers reflect the default SPI pins for Uno and Nano models

  The circuit:

    SD card attached to SPI bus as follows:

 
*/
  // include the SD library:

  // set up variables using the SD utility library functions:

  Sd2Card card;

  SdVolume volume;

  SdFile root;

  const int chipSelect = 4;



  Serial.print("\nInitializing SD card...");

  // we'll use the initialization code from the utility libraries

  // since we're just testing if the card is working!

  if (!card.init(SPI_HALF_SPEED, chipSelect)) {

    Serial.println("initialization failed. Things to check:");

    Serial.println("* is a card inserted?");

    Serial.println("* is your wiring correct?");

    Serial.println("* did you change the chipSelect pin to match your shield or module?");

    while (1)
      ;

  } else {

    Serial.println("Wiring is correct and a card is present.");
  }

  // print the type of card

  Serial.println();

  Serial.print("Card type:         ");

  switch (card.type()) {

    case SD_CARD_TYPE_SD1:

      Serial.println("SD1");

      break;

    case SD_CARD_TYPE_SD2:

      Serial.println("SD2");

      break;

    case SD_CARD_TYPE_SDHC:

      Serial.println("SDHC");

      break;

    default:

      Serial.println("Unknown");
  }

  // Now we will try to open the 'volume'/'partition' - it should be FAT16 or FAT32

  if (!volume.init(card)) {

    Serial.println("Could not find FAT16/FAT32 partition.\nMake sure you've formatted the card");

    while (1)
      ;
  }

  Serial.print("Clusters:          ");

  Serial.println(volume.clusterCount());

  Serial.print("Blocks x Cluster:  ");

  Serial.println(volume.blocksPerCluster());

  Serial.print("Total Blocks:      ");

  Serial.println(volume.blocksPerCluster() * volume.clusterCount());

  Serial.println();

  // print the type and size of the first FAT-type volume

  uint32_t volumesize;

  Serial.print("Volume type is:    FAT");

  Serial.println(volume.fatType(), DEC);

  volumesize = volume.blocksPerCluster();  // clusters are collections of blocks

  volumesize *= volume.clusterCount();  // we'll have a lot of clusters

  volumesize /= 2;  // SD card blocks are always 512 bytes (2 blocks are 1KB)

  Serial.print("Volume size (Kb):  ");

  Serial.println(volumesize);

  Serial.print("Volume size (Mb):  ");

  volumesize /= 1024;

  Serial.println(volumesize);

  Serial.print("Volume size (Gb):  ");

  Serial.println((float)volumesize / 1024.0);

  Serial.println("\nFiles found on the card (name, date and size in bytes): ");

  root.openRoot(volume);

  // list all files in the card with date and size

  root.ls(LS_R | LS_DATE | LS_SIZE);

  root.close();
}

bool sdcard_clear() {
  SD.remove("DATALOG.TXT");
  if (SD.exists("DATALOG.TXT")) {
    Serial.println("error deleting datalog.txt");
    return false;
  } else {
    return true;
  }
}