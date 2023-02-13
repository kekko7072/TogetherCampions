import csv
import json
import uuid
from datetime import datetime, timedelta

# Apri il file di testo
with open("DATALOG.TXT", "r") as file:
    data = file.read().split(",")

# Crea un nuovo file CSV
with open("datalog.csv", "w", newline="") as file:
    writer = csv.writer(file)
    
    # Scrive i dati nel file CSV
    for line in data:
        line_data = line.split(";")
        writer.writerow(line_data)

# Apri il file CSV
with open("datalog.csv", "r") as file:
    reader = csv.reader(file)
    data = list(reader)

# Crea un dizionario per contenere tutti i dati del file CSV
json_data = []
last_timestamp = 0

# Loop through each row of data
for row in data:
    if row[0] == "SYSTEM":
        json_data.append({
            "system":
                    { 
                      "timestamp": int(row[1]),
                      "battery":  int(row[2]),
                      "temperature":float((int(row[3]) / 340.00) + 36.53)
                    }
            })
    elif  row[0] == "GPS_POSITION":
        json_data.append({
            "gps_position":
                    {
                      "timestamp": int(row[1]),
                      "available": row[2]== "true",
                      "lat": float(row[3]),
                      "lng": float(row[4]),
                      "speed": float(row[5])
                   }
            })
    elif  row[0] == "GPS_NAVIGATION":
        json_data.append({
            "gps_navigation":
                    {
                      "timestamp": int(row[1]),
                      "available": row[2] == "true",
                      "altitude": float(row[3]),
                      "course": float(row[4]),
                      "variation": float(row[5])
                   }
            })
    elif  row[0] == "MPU_ACCELERATION":
        json_data.append({
                 "accelerometer":
                   {
                     "timestamp": int(row[1]),
                     "x": int(row[2]),
                     "y": int(row[3]),
                     "z": int(row[4])
                    }
        })
    elif  row[0] == "MPU_GYROSCOPE":
        last_timestamp = row[1]
        json_data.append({
                 "gyroscope":
                   {
                     "timestamp": int(row[1]),
                     "x": int(row[2]),
                     "y": int(row[3]),
                     "z": int(row[4])
                    }
        })


#Insert user input
session_id = uuid.uuid1()
print("Session id: " + str(session_id))

print("Device id: 9192B9E2-64A0-91B3-D73D-351BCE2D4858") #TODO remove this and make in app user a way to copy it
device_id = "9192B9E2-64A0-91B3-D73D-351BCE2D4858"#input("Enter device id: ")

start_timestamp = datetime.today() #TODO take start timestamp from user input
end_timestamp = start_timestamp + timedelta(milliseconds=int(last_timestamp))
# Crea una lista di timestamps raggruppando in un unico file json i dati
# che hanno lo stesso timestamp, ovvero che sono riferiti allo stesso istante
grouped_data = {"device_id":device_id,"session_id":str(session_id),"info":{"name":"Session imported from logs","start":str(start_timestamp),"end":str(end_timestamp)},"device_position":{"x":0,"y":0,"z":0},"timestamp":[]}

#TODO FIXARE CONVERSIONE DI JSON CHE APP E QUESTO CODICE DANNO RISULTATI DIVERSI!
middle_json ={}
for item in json_data:
    for key, value in item.items():
        timestamp = value['timestamp']
        middle_json[key] = value
        if(key=="gyroscope"):
            grouped_data['timestamp'].append(middle_json)
            middle_json={}

        #print(key)
        #print(value)
        #print(timestamp)
        #if (key=="system"):


        #if timestamp not in grouped_data:
        #    grouped_data[timestamp] = []
        #grouped_data['timestamp'].append({key: value})

            
# Converti il dizionario in un file JSON
with open(str(session_id)+".json", "w") as file:
    json.dump(grouped_data, file)