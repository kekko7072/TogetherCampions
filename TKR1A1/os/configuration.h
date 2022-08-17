//SETTINGS
/*
  Device model number
*/
#define MODEL_NUMBER "TKR1A1"

/*
  Set a new device_id unique for every new device released using AAAA0000AAAA scheme (URL ENDPOINT TO GENERATE).
  The SERIAL_NUMBER should be printed and given to the user to configure the device for his account.
*/
#define SERIAL_NUMBER "RA207twQF5LawcErH8j"

/*
  CLOCK: Is the time the code run in loop fetching data from GPS to SERVER [aproximatly]. 
    Ex. clock = 60  Means run 60 times then data are send
*/
#define CLOCK 6

/* 
  Sim parameters for connction of GPRS service
*/
#define SECRET_PINNUMBER "1503"  //1503
#define SECRET_GPRS_APN "TM"     // internet.it
#define SECRET_GPRS_LOGIN ""     // replace with your GPRS login
#define SECRET_GPRS_PASSWORD ""  // replace with your GPRS password



/// ADVANCED SETTINGS

/*
  Server address and enpionds witch are used to store data on the cloud.
  Link to dashboard: https://console.cloud.google.com/appengine?project=together-champions&supportedpurview=project&serviceId=default
*/
#define SERVER_ADDRESS "together-champions.ew.r.appspot.com"
#define SERVER_SETTINGS "/settings?serialNumber="
#define SERVER_POST "/post?serialNumber="