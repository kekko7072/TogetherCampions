bool cloud_save(HttpClient http, Settings settings, String input_data) {

  //PREPARE DATA TO SEND TO SERVER
  char content_type[] = "application/x-www-form-urlencoded";
  String post_data = "clock=" + String(DEVICE_CLOCK) + "&frequency=" + String(settings.frequency) + input_data;

  Serial.println();
  Serial.println("Making POST request");
  Serial.println(post_data);
  Serial.println();

  //POST DATA
  int err = http.post(String(SERVER_POST) + String(DEVICE_SERIAL_NUMBER), content_type, post_data);
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
      http.stop();

      return true;

    } else {
      Serial.println("Getting response failed: " + String(err));

      return false;
    }

  } else {
    Serial.println("Connect failed: " + String(err));
    await_seconds(10);

    return false;
  }
}