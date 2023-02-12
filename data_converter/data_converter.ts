/*import * as fs from "fs";
import * as csv from "csv-parse/lib/sync";

const dataLogTxt = fs.readFileSync("datalog.txt", "utf-8");
const data = dataLogTxt.split(",");

// Crea un nuovo file CSV
const csvData = [];
for (const line of data) {
  const lineData = line.split(";");
  csvData.push(lineData);
}

fs.writeFileSync("datalog.csv", csv.unparse(csvData), "utf-8");

const csvDataLog = fs.readFileSync("datalog.csv", "utf-8");
const parsedCsvData = csv.parse(csvDataLog, { columns: true });

// Crea un dizionario per contenere tutti i dati del file CSV
const jsonData = [];

// Loop through each row of data
for (const row of parsedCsvData) {
  if (row[0] === "SYSTEM") {
    jsonData.push({
      system: {
        timestamp: row[1],
        battery: row[2],
        temperature: row[3],
      },
    });
  } else if (row[0] === "GPS_POSITION") {
    jsonData.push({
      gps_position: {
        timestamp: row[1],
        available: row[2],
        lat: row[3],
        lng: row[4],
        speed: row[5],
      },
    });
  } else if (row[0] === "GPS_NAVIGATION") {
    jsonData.push({
      gps_navigation: {
        timestamp: row[1],
        available: row[2],
        altitude: row[3],
        course: row[4],
        magnetic_variation: row[5],
      },
    });
  } else if (row[0] === "MPU_ACCELERATION") {
    jsonData.push({
      mpu_acceleration: {
        timestamp: row[1],
        x: row[2],
        y: row[3],
        z: row[4],
      },
    });
  } else if (row[0] === "MPU_GYROSCOPE") {
    jsonData.push({
      mpu_gyroscope: {
        timestamp: row[1],
        x: row[2],
        y: row[3],
        z: row[4],
      },
    });
  }
}

// Crea una lista di timestamps raggruppando in un unico file json i dati
// che hanno lo stesso timestamp, ovvero che sono riferiti allo stesso istante
const groupedData = {};

for (const item of jsonData) {
  for (const [key, value] of Object.entries(item)) {
    const timestamp = value.timestamp;
    if (!groupedData[timestamp]) {
      groupedData[timestamp] = [];
    }
    groupedData[timestamp].push({ [key]: value });
  }
}
*/
