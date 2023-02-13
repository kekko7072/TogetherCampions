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
                      "latitude": float(row[3]),
                      "longitude": float(row[4]),
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
                     "aX": int(row[2]),
                     "aY": int(row[3]),
                     "aZ": int(row[4])
                    }
        })
    elif  row[0] == "MPU_GYROSCOPE":
        last_timestamp = row[1]
        json_data.append({
                 "gyroscope":
                   {
                     "timestamp": int(row[1]),
                     "gX": int(row[2]),
                     "gY": int(row[3]),
                     "gZ": int(row[4])
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

utility_json ={}
for item in json_data:
    for key, value in item.items():
        timestamp = value['timestamp']
        if key == "system":
            utility_json[key] = value
        elif timestamp==utility_json["system"]['timestamp']:
            utility_json[key] = value
            if(key=="gyroscope"):
                grouped_data['timestamp'].append(utility_json)
                utility_json={}
        else:
            print("!Found one data without marching timestamp")
            print(item)
            
# Converti il dizionario in un file JSON
with open(str(session_id)+".json", "w") as file:
    json.dump(grouped_data, file)