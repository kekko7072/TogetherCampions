import 'package:intl/intl.dart';
import 'imports.dart';

class CalculationService {
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

  static TelemetryAnalytics telemetry({
    required List<Gps> gps,
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

    int satellites = 0;

    double batteryMax = 0;
    double batteryMin = 10000;

    for (Gps log in gps) {
      ///Speed
      speedMedium = speedMedium + log.speed;

      if (speedMax < log.speed) {
        speedMax =
            CalculationService.roundDouble(number: log.speed, decimal: 3);
      }

      if (speedMin > log.speed) {
        speedMin =
            CalculationService.roundDouble(number: log.speed, decimal: 3);
      }

      ///Altitude
      altitudeMedium = altitudeMedium + log.altitude;

      if (altitudeMax < log.altitude) {
        altitudeMax =
            CalculationService.roundDouble(number: log.altitude, decimal: 3);
      }

      if (altitudeMin > log.altitude) {
        altitudeMin =
            CalculationService.roundDouble(number: log.altitude, decimal: 3);
      }

      ///Course
      courseMedium = courseMedium + log.course;

      if (courseMax < log.course) {
        courseMax =
            CalculationService.roundDouble(number: log.course, decimal: 3);
      }

      if (courseMin > log.course) {
        courseMin =
            CalculationService.roundDouble(number: log.course, decimal: 3);
      }

      ///Satellites
      satellites = satellites + log.satellites;

      /*///Battery
      if (batteryMax < log.) {
        batteryMax = log.battery;
      }

      if (batteryMin > log.battery) {
        batteryMin = log.battery;
      }*/
    }

    return TelemetryAnalytics(
      speed: RangeAnalytics(
        medium: CalculationService.roundDouble(
            number: speedMedium / gps.length, decimal: 3),
        max: speedMax,
        min: speedMin,
      ),
      altitude: RangeAnalytics(
        medium: CalculationService.roundDouble(
            number: altitudeMedium / gps.length, decimal: 3),
        max: altitudeMax,
        min: altitudeMin,
      ),
      course: RangeAnalytics(
        medium: CalculationService.roundDouble(
            number: courseMedium / gps.length, decimal: 3),
        max: courseMax,
        min: courseMin,
      ),
      distance: MapService.findDistanceFromList(segment).roundToDouble(),
      satellites: satellites ~/ gps.length,
      /* battery: Battery(
        consumption: CalculationService.roundDouble(
            number: batteryMax - batteryMin, decimal: 3),
        start: batteryMax,
        minVoltage: batteryMin,
      ),*/
    );
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

  static String timestamp(int input) {
    Duration duration = Duration(milliseconds: input);
    return '${duration.inHours < 1 ? '' : '${duration.inHours}:'}${duration.inMinutes.remainder(60) < 10 ? '0${duration.inMinutes.remainder(60)}' : duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60) < 10 ? '0${duration.inSeconds.remainder(60)}' : duration.inSeconds.remainder(60)}';
  }

  /* static String chartTimestamp(DateTime duration) {
    return '${duration.hour < 1 ? '' : '${duration.hour}:'}${duration.hour < 10 ? '0${duration.minute}' : duration.minute}:${duration.second < 10 ? '0${duration.second.remainder(60)}' : duration.second.remainder(60)}';
  }*/

  static double temperature(int input) => (input / 340.00) + 36.53;

  static double mediumAcceleration(Mpu input) =>
      sqrt(pow(input.aX / 16384.0, 2) +
          pow(input.aY / 16384.0, 2) +
          pow(input.aZ / 16384.0, 2));

  static int pitch(Mpu input) =>
      (atan2(input.aX, sqrt(input.aY * input.aY + input.aZ * input.aZ)) * 57.3)
          .toInt();

  static int roll(Mpu input) => (atan2(input.aY, input.aZ) * 57.3).toInt();
}
