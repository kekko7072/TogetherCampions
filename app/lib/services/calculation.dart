import 'imports.dart';

class CalculationService {
  static double findDistanceFromList(List<LatLng> list) {
    int i = 0;
    double distance = 0;
    for (i = 0; i < list.length - 1; i++) {
      distance = distance + findDistance(list[i], list[i + 1]);
    }
    return distance;
  }

  static double findDistance(LatLng from, LatLng to) {
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

  static LatLng findCenter(LatLng from, LatLng to) {
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

  static String formatDate({required DateTime date, required bool seconds}) {
    return '${date.hour < 10 ? '0${date.hour}' : date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}${seconds ? ':${date.second < 10 ? '0${date.second}' : date.second}' : ''}   ${date.day}/${date.month}/${date.year}';
  }

  static initialCameraPosition(
      {required List<LatLng> list, required bool isPreview}) {
    LatLng start = list.first;
    LatLng end = list.first;
    double distance = 0;

    //Find two more distant points
    for (LatLng latLng in list) {
      double newDistance = findDistance(start, latLng);
      if (distance < newDistance) {
        end = latLng;
        distance = newDistance;
      }
    }

    return CameraPosition(
        target: findCenter(start, end),
        zoom: 18.5 - (isPreview ? (1.6 * distance) : (1.35 * distance)));
  }

  static Telemetry telemetry({
    required List<Log> logs,
    required List<LatLng> segment,
  }) {
    double speedMedium = 0;
    double speedMax = 0;
    double speedMin = 10000;

    double altitudeMedium = 0;
    double altitudeMax = 0;
    double altitudeMin = 10000;

    double batteryMax = 0;
    double batteryMin = 10000;

    for (Log log in logs) {
      //Speed
      speedMedium = speedMedium + log.gps.speed;

      if (speedMax < log.gps.speed) {
        speedMax =
            CalculationService.roundDouble(number: log.gps.speed, decimal: 3);
      }

      if (speedMin > log.gps.speed) {
        speedMin =
            CalculationService.roundDouble(number: log.gps.speed, decimal: 3);
      }

      //Altitude
      altitudeMedium = altitudeMedium + log.gps.altitude;

      if (altitudeMax < log.gps.altitude) {
        altitudeMax = CalculationService.roundDouble(
            number: log.gps.altitude, decimal: 3);
      }

      if (altitudeMin > log.gps.altitude) {
        altitudeMin = CalculationService.roundDouble(
            number: log.gps.altitude, decimal: 3);
      }

      //Battery
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
    if (seconds < 60) {
      return '$seconds s';
    } else {
      double minutes = seconds / 60;
      return '$minutes min';
    }
  }
}
