import 'package:intl/intl.dart';

import 'imports.dart';

class CalculationService {
  static int findFastestLogFromList(List<Log> list) {
    int i = 0;
    double speed = 0;
    int index = 0;
    for (i = 0; i < list.length - 1; i++) {
      if (list[i].gps.speed > speed) {
        speed = list[i].gps.speed;
        index = i;
      }
    }
    return index;
  }

  static double findDistanceFromList(List<MapLatLng> list) {
    int i = 0;
    double distance = 0;
    for (i = 0; i < list.length - 1; i++) {
      distance = distance + findDistance(list[i], list[i + 1]);
    }
    return distance;
  }

  static double findDistance(MapLatLng from, MapLatLng to) {
    double lat1 = toRadian(from.latitude);
    double lng1 = toRadian(from.longitude);
    double lat2 = toRadian(to.latitude);
    double lng2 = toRadian(to.longitude);

    //Haversine Formula
    double dLong = lng2 - lng1;
    double dLat = lat2 - lat1;

    var res = pow(sin((dLat / 2)), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLong / 2), 2);
    res = 2 * asin(sqrt(res));
    double R = 6371;
    res = res * R;
    return res;
  }

  static LatLng findCenter(MapLatLng from, MapLatLng to) {
    //Find the center of the two points
    double lat1 = toRadian(from.latitude);
    double lng1 = toRadian(from.longitude);
    double lat2 = toRadian(to.latitude);
    double lng2 = toRadian(to.longitude);

    double dLong = lng2 - lng1;

    double bx = cos(lat2) * cos(dLong);
    double by = cos(lat2) * sin(dLong);

    double latMidway = toDegrees(atan2(sin(lat1) + sin(lat2),
        sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by)));
    double lngMidway = toDegrees(lng1 + atan2(by, cos(lat1) + bx));

    return LatLng(latMidway, lngMidway);
  }

  static double roundDouble({required double number, required int decimal}) {
    return double.parse(number.toStringAsFixed(decimal));
  }

  static String formatDate(
      {required DateTime date, required bool year, required bool seconds}) {
    if (year) {
      return DateFormat('kk:mm   dd/MM/yyyy').format(date);
    } else {
      return DateFormat('kk:mm   dd/MM').format(date);
    }
  }

  static initialCameraPosition(
      {required List<MapLatLng> list, required bool isPreview}) {
    MapLatLng start = list.first;
    MapLatLng end = list.first;
    double distance = 0;

    //Find two more distant points
    for (MapLatLng latLng in list) {
      double newDistance = findDistance(start, latLng);
      if (distance < newDistance) {
        end = latLng;
        distance = newDistance;
      }
    }
    double zoom = 0.0;
    if (distance < 10) {
      if (isPreview) {
        zoom = 18.5 - 1.6 * distance;
      } else {
        zoom = 18.5 - 1.35 * distance;
      }
    } else if (distance < 20) {
      zoom = 12.5;
    } else if (distance < 30) {
      zoom = 11.5;
    } else {
      zoom = 10.5;
    }

    return CameraPosition(target: findCenter(start, end), zoom: zoom);
  }

  static Telemetry telemetry({
    required List<Log> logs,
    required List<MapLatLng> segment,
  }) {
    double speedMedium = 0;
    double speedMax = 0;
    double speedMin = 10000;

    double altitudeMedium = 0;
    double altitudeMax = 0;
    double altitudeMin = 10000;

    double courseMedium = 0;
    double courseMax = 0;
    double courseMin = 10000;

    double batteryMax = 0;
    double batteryMin = 10000;

    for (Log log in logs) {
      ///Speed
      speedMedium = speedMedium + log.gps.speed;

      if (speedMax < log.gps.speed) {
        speedMax =
            CalculationService.roundDouble(number: log.gps.speed, decimal: 3);
      }

      if (speedMin > log.gps.speed) {
        speedMin =
            CalculationService.roundDouble(number: log.gps.speed, decimal: 3);
      }

      ///Altitude
      altitudeMedium = altitudeMedium + log.gps.altitude;

      if (altitudeMax < log.gps.altitude) {
        altitudeMax = CalculationService.roundDouble(
            number: log.gps.altitude, decimal: 3);
      }

      if (altitudeMin > log.gps.altitude) {
        altitudeMin = CalculationService.roundDouble(
            number: log.gps.altitude, decimal: 3);
      }

      ///Course
      courseMedium = courseMedium + log.gps.course;

      if (courseMax < log.gps.course) {
        courseMax =
            CalculationService.roundDouble(number: log.gps.course, decimal: 3);
      }

      if (courseMin > log.gps.course) {
        courseMin =
            CalculationService.roundDouble(number: log.gps.course, decimal: 3);
      }

      ///Battery
      if (batteryMax < log.battery) {
        batteryMax = log.battery;
      }

      if (batteryMin > log.battery) {
        batteryMin = log.battery;
      }
    }

    return Telemetry(
        speed: Range(
          medium: CalculationService.roundDouble(
              number: speedMedium / logs.length, decimal: 3),
          max: speedMax,
          min: speedMin,
        ),
        altitude: Range(
          medium: CalculationService.roundDouble(
              number: altitudeMedium / logs.length, decimal: 3),
          max: altitudeMax,
          min: altitudeMin,
        ),
        course: Range(
          medium: CalculationService.roundDouble(
              number: courseMedium / logs.length, decimal: 3),
          max: courseMax,
          min: courseMin,
        ),
        distance:
            CalculationService.findDistanceFromList(segment).roundToDouble(),
        battery: Battery(
          consumption: CalculationService.roundDouble(
              number: batteryMax - batteryMin, decimal: 3),
          maxVoltage: batteryMax,
          minVoltage: batteryMin,
        ));
  }

  static double toRadian(double degree) {
    double oneDeg = (pi) / 180;
    return (oneDeg * degree);
  }

  static double toDegrees(double radian) {
    double oneRadian = 180 / (pi);
    return (oneRadian * radian);
  }

  static formatTime({required int seconds}) {
    if (seconds <= 60) {
      return '$seconds s';
    } else {
      Duration time = Duration(seconds: seconds);
      return '${time.inMinutes} min  ${time.inSeconds - 60 * time.inMinutes} s';
    }
  }

  static int calculateBatteryPercentage({required double volts}) {
    return (100 * volts ~/ 4.2);
  }

  static String formatOutputWithNewTimestamp(
      {required String input, required DateTime start}) {
    debugPrint(input);

    ///SPLIT
    debugPrint("\nSPLIT");
    List<String> original = input.split("&");
    //debugPrint("$original");
    List<String> originalTimestamp =
        original.where((el) => el.contains("timestamp=")).toList();
    //debugPrint("ORIGINAL TIMESTAMP: $originalTimestamp");

    //New timestamp
    List<String> newTimestamp = [];
    for (String value in originalTimestamp) {
      newTimestamp.add(
          "timestamp=${(start.millisecondsSinceEpoch + int.parse(value.replaceAll("timestamp=", ""))) ~/ 1000}");
    }
    //debugPrint("NEW TIMESTAMP: $newTimestamp");

    //Remove old timestamp
    original.removeWhere((el) => el.contains("timestamp="));
    //debugPrint("$original");

    ///RECOMBINE
    debugPrint("\nRECOMBINE");
    original.addAll(newTimestamp);
    String output = "";
    for (String val in original) {
      if (val != "") {
        output = "$output&$val";
      }
    }
    return output;
  }

  static DateTime getLastNewTimestamp(
      {required String lastInput, required DateTime start}) {
    debugPrint(lastInput);

    ///SPLIT
    debugPrint("\nSPLIT");
    List<String> original = lastInput.split("&");
    debugPrint("$original");
    List<String> originalTimestamp =
        original.where((el) => el.contains("timestamp=")).toList();
    debugPrint("ORIGINAL TIMESTAMP: $originalTimestamp");

    return start.add(Duration(
        milliseconds:
            int.parse(originalTimestamp.last.replaceAll("timestamp=", ""))));
  }
}
