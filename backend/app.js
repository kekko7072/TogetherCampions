"use strict";

const admin = require("firebase-admin");
const { Timestamp } = require("firebase-admin/firestore");
const express = require("express");
const app = express();
const cors = require("cors");

app.use(cors());
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

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
      res.sendStatus(404);
    }
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
      //UNFORTIUNATLY ON THINGSMOBILE SIM THE TIMESTAM IS WRONG...
      //const time = value.timestamp[i] * 1000;
      const time = Date.now() + i * value.frequency * 1000;

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
            course:
              value.course[i] != null ? parseFloat(value.course[i]) : null,
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

const PORT = parseInt(process.env.PORT) || 8080;

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log("Press Ctrl+C to quit.");
});

module.exports = app;
