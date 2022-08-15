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
  let id = req.query.id;

  if (id != null) {
    var documentSnapshot = await admin
      .firestore()
      .collection("devices")
      .doc(id)
      .get();

    const clock = documentSnapshot.data().clock;
    const frequency = documentSnapshot.data().frequency;

    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(`{"clock": ${clock},"frequency": ${frequency}}`);
  } else {
    res.writeHesad(400, { "Content-Type": "text/html" });
    res.end(`Please send an id as query to get results`);
  }
});

app.post("/post", async (req, res) => {
  const uid = req.query.uid;

  const val = JSON.parse(JSON.stringify(req.body));
  console.log("INPUT: " + val.input);
  console.log("FREQUENCY: " + val.frequency);

  const jsonData = JSON.parse(val.input);

  for (var i = 0; i < jsonData.data.length ?? 0; i++) {
    const value = jsonData.data[i];
    const timestamp = value.timestamp * 1000;
    console.log(value);
    console.log(timestamp);
    await admin
      .firestore()
      .collection("devices")
      .doc(uid)
      .collection("logs")
      .doc(`${timestamp}`)
      .set({
        timestamp: Timestamp.fromMillis(timestamp),
        battery: parseFloat(value.battery),
        gps: {
          latitude: parseFloat(value.latitude),
          longitude: parseFloat(value.longitude),
          altitude: parseFloat(value.altitude),
          speed: parseFloat(value.speed),
          course: value.course != null ? parseFloat(value.course) : null,
          satellites: parseInt(value.satellites),
        },
      });
  }
  res.sendStatus(200);
});

const PORT = parseInt(process.env.PORT) || 8080;

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log("Press Ctrl+C to quit.");
});

module.exports = app;
