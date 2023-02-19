# Together Campions - GPS Tracker Project
_Together we create champions_

Together Campions is an **open-source project** aimed at creating a low-cost GPS tracker device that can be used to track sport performance and other items. The project consists of **hardware schematics**, **firmware** based on Arduino, and a Flutter **app** for macOS, Windows, Linux, iOS and Android called StoneApp to control the device .

## Hardware
The hardware for Together Campions includes two versions of the GPS tracker. 

TKR1A1: GPS Tracker + Bluetooth
TKR1B1: GPS Tracker + MQTT Technology

### TKR1A1
The **TKR1A1** is a GPS tracker that is connected to the user app (Stone App) using Bluetooth technology. Using the app for mobile available on the AppStore and PlayStore you can connect to the device staning at 10 meter maximum form it and traking live. Only one user can be connected to the device per session. You can also use the device without the app thanks the build-in SDCARD and then upload the data to visualize them.

### TKR1B1
The **TKR1B1** is a GPS tracker that is connected to the user app (Stone App) using MQTT technology. You will need a sim with data plan to connect. Using the app for mobile available on the AppStore and PlayStore you can connect to the device form wherever you want and also having multiple user connected to it and traking live. You can also use the device without the app thanks the build-in SDCARD and then upload the data to visualize them.


Both versions of the hardware include a GPS module, a microcontroller, an accelerometer and an SDCARD reader.

## Firmware

The firmware for Together Campions is based on Arduino and is designed to be easily modifiable by developers. The firmware includes code for controlling the GPS module, Bluetooth or MQTT module, and other sensors that can be added to the device.

### TKR1A1 
You don't need additional configuration for BLE. Simply compile and upload it.

### TKR1B1 
You need to configure the SIM apn info based on what sim you have. Then you need to create an MQTT Server and add the Server info on the configuration file. You can create a Server for free using [shiftr.io Cloud](https://cloud.shiftr.io) the limit is that you can use only for 6 hours per day.
You will need to set up your own MQTT server. Here are the steps to set up your own MQTT server:

Choose an MQTT server software: There are several MQTT server software options available, including Mosquitto, HiveMQ, and EMQ X. Choose one that fits your needs and install it on a server.
Configure the MQTT server: Once the MQTT server software is installed, you will need to configure it. This will involve setting up users and permissions, configuring security settings, and setting up topics for the TKR1B1 GPS tracker to publish and subscribe to.
Update the TKR1B1 firmware: The TKR1B1 firmware will need to be updated to use your MQTT server. You will need to update the code to connect to your MQTT server and publish and subscribe to the appropriate topics.
Update the StoneApp: The StoneApp will also need to be updated to connect to your MQTT server. You will need to update the code to connect to your server and subscribe to the appropriate topics.

## StoneApp

The StoneApp is a Flutter app designed to control the Together Campions GPS tracker. The app includes features for tracking the device's location, setting geofences, and receiving notifications when the device enters or exits a geofenced area.

### Download (macOS, Windows, Linux)
You can download the app from the [release note](https://github.com/kekko7072/lms/releases/tag/0.0.2) page.

### Mobile (iOS, Android)

You can find the app for free on the AppStores for iOS and PlayStore for Android.


