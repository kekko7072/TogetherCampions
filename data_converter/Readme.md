# DATA BLUEPRINT

In this system we have this type of data:
    + SYSTEM
    + GPS_POSITION
    + GPS_NAVIGATION
    + MPU_ACCELERATION
    + MPU_GYROSCOPE

Insert the file DATALOG.TXT in the current directory (DATA_COVERTER/.) and then run in terminal the command python3 data_converter.py

Remember to leave an empty file named DATALOG.TXT in the SDCARD, otherwise the tracker device will return an error of missing file.

## Structure
This are the caracters used to store data:

, is the vector separator
; is the data separator
: is the field separator

## SYSTEM

type:SYSTEM;timestamp:4508;battery:-227;temp:-5040,

This data collected by the MPU sensor and internal infos

## GPS_POSITION

type:GPS_POSITION;timestamp:4508.00;available:0.00;lat:0.0000000;lng:0.0000000;speed:0.0000000,

This data collected by the GPS sensor


## GPS_NAVIGATION

type:GPS_NAVIGATION;timestamp:4508.00;available:0.00;altitude:0.0000;course:0.0000;magneticVariation:0.0000,

This data collected by the GPS sensor


## MPU_ACCELERATION

type:MPU_ACCELERATION;timestamp:4508;acX:-1812;acY:-3032;acZ:17152,

This data collected by the MPU sensor


## MPU_GYROSCOPE

type:MPU_GYROSCOPE;timestamp:4508;gyX:-254;gyY:42;gyZ:76,

This data collected by the MPU sensor
