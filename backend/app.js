"use strict";

const admin = require("firebase-admin");
const { Timestamp } = require("firebase-admin/firestore");
const express = require("express");
const app = express();
const cors = require("cors");
const axios = require("axios");

app.use(cors());
app.use(express.urlencoded({ extended: false }));
// fixing "413 Request Entity Too Large" errors
app.use(express.json({ limit: "10mb", extended: true }));
app.use(
  express.urlencoded({ limit: "10mb", extended: true, parameterLimit: 50000 })
);

const serviceAccount = {
  type: "service_account",
  projectId: "together-champions",
  privateKeyId: "e035e105a41ecb67ec8a2f2733d1fd6d0550a7db",
  privateKey:
    "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCoi216V4zaK/bQ\nsFwGIRYVvaOeS1lTwoeUdPpQjHcHKcxv8yMBgrAZftGiStH6evW03GiRWCj7Mrtl\nvFyiwVF/lnk439ci87e9aIZqjHp5tT3RnEfvE7PTnzuzJ/UeThcYOjF1zUocg4jF\nJCDwEi+YAsZxAnZHAkNgo4amPpT8W/HnWBu/tWQFs34Dx22hnZOSTc0feLB3T8/W\n3hLfyjdPlQceNaoJ0IecbZ84mlfpOEJ6oBXN79yt3e1BG3wBmDOhVqAONeG5rlgC\nAKIbHvH/DOkkQPXp9yIirEw0LCfJrht6Pl75NTr+HQAoelRiX/PR8HDArSBOXAkO\ny+q2NeCLAgMBAAECggEAClvncqmG4rHpDZKJVWcbMGLjd4syBk/ifWFjMSgw+KO9\nCPRspl8d67M7tznaBgcgqukRFD3S5v2LPwmAuBAhrjHVaYV4d5F7LY0LFelkba6S\nChwM38jaOJuE09IU4rPx/280MwVXFMGQ2m0KCTdU7YbeI3v/QQYGlh323KjkB06V\n1DA11Vg05gTP3C7B4BieKzQel6dvTs0EwF6YnpWS2C7osA/8ItkHVkcqfn+28LIh\nt7qmtcguMg0J64VOTmAN8xVsgy0StKjuhle+c/zxn/BIY8EFe5UJAVUW2mlAliql\ncuEKmDF7VDNKStsENlPmNgqZrybB/fmcr8l+LRwYIQKBgQDZYRfnnm9oA61AwdLr\nJcF3ZNvpEqtzsB6QaVyDtZfNrO5kWKHwFXKuD0qZy0VQbm7c53cDB+x5juiQCSHT\nbH+rcXw9Up9bmScIpqpfFXejMpoVJ7O4ux6vBa9jzhtVQnYmjfnFTY3pFdD7ofJi\nMTa7YNHSpDp4uKtFHHRJG+sxbwKBgQDGfTk2EJ6Qld85YZD6jHramZjtN2HEpNoU\nHz9mKQpowtNSwfmn+qXo2T5tjTk6TDI8hu811BDcwC7R3ssFI5A/yfNTL+uRdPPp\n+Av6lhbO3qGVciqF2geyhJOmFDM0sbje9ohiLAezKrx6mgXYLRYepGup8rpFqcyP\nfQIWogc8pQKBgQCTievQn98baMtxlVwTj7ek0obTxYEq7xF/kJNjLaBPz5yp7OJU\ncio461YF1kpAUgPa2RsUqo8c3hsIj7oupohsk4TwliBk6ijtHTmreYWO9axQyXaY\n3h/wSNqG0gAJOSe5+UjaWk4EMnN6Jqu9a4urWAZxglfRUf2k1bAzYsiZ7wKBgQCd\ngJh5Uk7ApGxxd/43EmoaNG+pLJ0kETwLY5BHXKGp548QyGN26+njDx/+hmW24Oes\nJ9aBfDm1Mbr1RjkLZuD7/SBcDlZ7Iba7Hd1Dhv2qQfcuQ12CwTQCcDlJPBY15iCw\nrCgk3pNtlKfjEX05wO0ge5ADV1yAEvEDm0qg8wmTEQKBgB2LNyGA6B6DdgkiVWj9\n8HYv2DDZfUH0BSTwi3td5j2jR9BMD4x45XwUwv6skkTBJoQdAHHNuu8U8/Dug3AC\nYecZ8cG/K5TrR8j8ia9+wjqZm+R8Jte6z//lDKodPD+YlfNvuZDWRoBz23zGFM96\nPwku3KAiZK/Qa3cPit8+3sLs\n-----END PRIVATE KEY-----\n",
  clientEmail:
    "firebase-adminsdk-2h3uf@together-champions.iam.gserviceaccount.com",
  clientId: "102852871404852694772",
  authUri: "https://accounts.google.com/o/oauth2/auth",
  tokenUri: "https://oauth2.googleapis.com/token",
  authProviderX509CertUrl: "https://www.googleapis.com/oauth2/v1/certs",
  clientC509CertUrl:
    "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-2h3uf%40together-champions.iam.gserviceaccount.com",
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

admin.firestore().settings({ ignoreUndefinedProperties: true });

app.get("/settings", async (req, res) => {
  try {
    const SERIAL_NUMBER = req.query.serialNumber;
    const MODEL_NUMBER = req.query.modelNumber;
    const CLOCK = req.query.clock;
    const SD_CARD_AVAILABLE = req.query.sdCardAvailable;

    const SOFTWARE_NAME = req.query.softwareName;
    const SOFTWARE_VERSION = req.query.softwareVersion;

    const document = await admin
      .firestore()
      .collection("devices")
      .doc(SERIAL_NUMBER)
      .get();

    if (document.exists) {
      await document.ref.update({
        modelNumber: MODEL_NUMBER,
        clock: parseInt(CLOCK),
        sdCardAvailable: SD_CARD_AVAILABLE == "true",
        software: {
          name: SOFTWARE_NAME,
          version: SOFTWARE_VERSION,
        },
      });

      const mode = document.data().mode;
      const frequency = document.data().frequency;

      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(`{"mode": "${mode}","frequency": ${frequency}}`);
    } else {
      res.writeHead(404, { "Content-Type": "plain/text" });
      res.end("Device not found, please register it before turning on.");
    }
  } catch (e) {
    console.log(e);
    res.sendStatus(400);
  }
});

app.post("/initialize", async (req, res) => {
  try {
    const SERIAL_NUMBER = req.query.serialNumber;

    const value = JSON.parse(JSON.stringify(req.body));

    await admin
      .firestore()
      .collection("devices")
      .doc(SERIAL_NUMBER)
      .set({
        modelNumber: value.modelNumber,
        clock: parseInt(value.clock),
        frequency: parseInt(value.frequency),
        sdCardAvailable: value.sdCardAvailable == "true",
        mode: value.mode,
        software: {
          name: value.softwareName,
          version: value.softwareVersion,
        },
      });

    res.sendStatus(200);
  } catch (e) {
    console.log(e);
    res.sendStatus(400);
  }
});

app.post("/post", async (req, res) => {
  try {
    const SERIAL_NUMBER = req.query.serialNumber;

    const value = JSON.parse(JSON.stringify(req.body));
    console.log("FREQUENCY: " + value.frequency);
    console.log("CLOCK: " + value.clock);

    console.log(req.body);

    for (var i = 0; i < value.clock ?? 0; i++) {
      const time = value.timestamp[i] * 1000;
      //UNFORTIUNATLY ON THINGSMOBILE SIM THE TIMESTAM IS WRONG...
      //const time = Date.now() + i * value.frequency * 1000;

      await admin
        .firestore()
        .collection("devices")
        .doc(SERIAL_NUMBER)
        .collection("logs")
        .doc(`${time}`)
        .set({
          timestamp: Timestamp.fromMillis(time),
          battery: parseFloat(value.battery[i]),
          gps: {
            latitude: parseFloat(value.latitude[i]),
            longitude: parseFloat(value.longitude[i]),
            altitude: parseFloat(value.altitude[i]),
            speed: parseFloat(value.speed[i]),
            course: parseFloat(value.course[i]),
            satellites: parseInt(value.satellites[i]),
          },
        });
    }
    res.sendStatus(200);
  } catch (e) {
    console.log(e);
    res.sendStatus(400);
  }
});

app.post("/upload", async (req, res) => {
  try {
    const value = req.body; //JSON.parse(JSON.stringify(req.body));
    console.log("DEVICE ID: " + value.deviceID);
    console.log("SESSION ID: " + value.sessionID);
    const DEVICE_ID = value.deviceID;
    const SESSION_ID = value.sessionID;

    const docSession = admin
      .firestore()
      .collection("devices")
      .doc(DEVICE_ID)
      .collection("sessions")
      .doc(SESSION_ID);

    res.sendStatus(200);

    //console.log(req.body);

    ///1. Create Session
    await docSession.set({
      info: {
        name: value.info.name,
        start: admin.firestore.Timestamp.fromDate(new Date(value.info.start)),
        end: admin.firestore.Timestamp.fromDate(new Date(value.info.end)),
      },
      devicePosition: {
        x: value.devicePosition.x,
        y: value.devicePosition.y,
        z: value.devicePosition.z,
      },
    });

    ///1. Add System
    console.log("Uploading services STARTED");
    for (var i = 0; i < value.system.length ?? 0; i++) {
      await docSession
        .collection("services")
        .doc(`${value.system[i].timestamp}`)
        .set({
          battery: value.system[i].battery,
          temperature: value.system[i].temperature,
        });
    }
    console.log("Uploading services COMPLETED");

    ///2. Add Gps
    console.log("Uploading gps STARTED");
    for (var k = 0; k < value.gps_position.length ?? 0; k++) {
      await docSession
        .collection("gps_position")
        .doc(`${value.gps_position[k].timestamp}`)
        .set({
          available: value.gps_position[k].available,
          latitude: value.gps_position[k].latitude,
          longitude: value.gps_position[k].longitude,
          speed: value.gps_position[k].speed,
        });
    }
    for (var j = 0; j < value.gps_navigation.length ?? 0; j++) {
      await docSession
        .collection("gps_navigation")
        .doc(`${value.gps_navigation[j].timestamp}`)
        .set({
          available: value.gps_navigation[j].available,
          altitude: value.gps_navigation[j].altitude,
          course: value.gps_navigation[j].course,
          variation: value.gps_navigation[j].variation,
        });
    }

    console.log("Uploading gps COMPLETED");

    ///3. Add Mpu
    console.log("Uploading mpu STARTED");

    for (var l = 0; l < value.accelerometer.length ?? 0; l++) {
      await docSession
        .collection("accelerometer")
        .doc(`${value.accelerometer[l].timestamp}`)
        .set({
          aX: value.accelerometer[l].aX,
          aY: value.accelerometer[l].aY,
          aZ: value.accelerometer[l].aZ,
        });
    }
    for (var m = 0; m < value.gyroscope.length ?? 0; m++) {
      await docSession
        .collection("gyroscope")
        .doc(`${value.gyroscope[m].timestamp}`)
        .set({
          gX: value.gyroscope[m].aX,
          gY: value.gyroscope[m].aY,
          gZ: value.gyroscope[m].aZ,
        });
    }
    console.log("Uploading mpu COMPLETED");

    ///TODO send notification to user process is finished....
  } catch (e) {
    console.log(e);
    res.sendStatus(400);
  }
});

app.get("/download", async (req, res) => {
  try {
    const SERIAL_NUMBER = req.query.serialNumber;
    const START_TIMESTAMP = req.query.startTimestamp;
    const END_TIMESTAMP = req.query.startTimestamp;
    const COMBINE_WEATHER = req.query.combineWeatthr;

    const device = await admin
      .firestore()
      .collection("devices")
      .doc(SERIAL_NUMBER)
      .get();

    if (device.exists) {
      const logs = await device.ref
        .collection("logs")
        .where(
          "timestamp",
          "<=",
          Timestamp.fromMillis(END_TIMESTAMP),
          ">=",
          Timestamp.fromMillis(START_TIMESTAMP)
        )
        .get();

      let output = {};
      let i = 0;

      //LIMIT to 100/month free then for each + 0,001 USD each other
      console.log(logs.lenght);

      for (i = 0; i < logs.lenght; i++) {
        if (COMBINE_WEATHER) {
          //TODO use this docs to develop https://rapidapi.com/darkskyapis/api/dark-sky/
          const options = {
            method: "GET",
            url: "https://dark-sky.p.rapidapi.com/37.774929,-122.419418,2019-02-20T00:22:01",
            headers: {
              "X-RapidAPI-Key":
                "5348a538e9mshde917c5524280abp1cc057jsn741def713239",
              "X-RapidAPI-Host": "dark-sky.p.rapidapi.com",
            },
          };
          axios
            .request(options)
            .then(function (response) {
              console.log(response.data);
            })
            .catch(function (error) {
              console.error(error);
            });

          axios
            .request(options)
            .then(function (response) {
              console.log(response.data);
            })
            .catch(function (error) {
              console.error(error);
            });
          await c;
          output.add({
            timestamp: logs[i].timestamp,
            battery: logs[i].battery,
            gps: {
              latitude: logs[i][gps].latitude,
              longitude: logs[i][gps].longitude,
              altitude: logs[i][gps].altitude,
              speed: logs[i][gps].speed,
              course: logs[i][gps].course,
              satellites: logs[i][gps].satellites,
            },
          });
        } else {
        }
      }

      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(output);
    } else {
      res.sendStatus(404);
    }
  } catch (e) {
    console.log(e);
    res.sendStatus(400);
  }
});

const PORT = parseInt(process.env.PORT) || 8080;

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log("Press Ctrl+C to quit.");
});

module.exports = app;
