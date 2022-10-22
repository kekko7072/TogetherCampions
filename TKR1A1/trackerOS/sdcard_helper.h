//OLD CODE

  /*// print GPS values
    Serial.print("Location: ");
    Serial.print(eulers[0], 7);
    Serial.print(", ");
    Serial.println(eulers[1], 7);

    Serial.print("Ground speed: ");
    Serial.print(eulers[2]);
    Serial.println(" km/h");

    Serial.print("Course: ");
    Serial.print(eulers[3]);
    Serial.println("m");

    Serial.print("Variation: ");
    Serial.println(eulers[4]);

    Serial.print("Millis: ");
    Serial.println(eulers[3]);*/



 /*
  if (central) {  // if a central is connected to the peripheral

    Serial.print("Connected to central: ");
    Serial.println(central.address());  // print the central's BT address


    digitalWrite(LED_BUILTIN, HIGH);  // turn on the LED to indicate the connection

    
    

    // while the central is connected:
    if (central.connected()) {
      long currentMillis = millis();

      //updateCompass(compassCharacteristic);
      while (GPS.available()) {
        updateGps(gpsCharacteristic);
      }

      if (currentMillis - previousMillis >= measurements_milliseconds) {
        //System
        updateTimestamp(timestampCharacteristic);
        updateBatteryLevel(batteryLevelCharacteristic);
        updateTemperature(temperatureCharacteristic);

        //Telemetry
        updateAcceleration(accelerometerCharacteristic);
        //updateSpeed(currentMillis - previousMillis, speedCharacteristic);
        updateGyroscope(gyroscopeCharacteristic);


        previousMillis = currentMillis;  //Clean to re-run cicle
      }
    }
    //Disconnected
    digitalWrite(LED_BUILTIN, LOW);

    Serial.print("Disconnected from central: ");
    Serial.println(central.address());*/