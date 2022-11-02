import 'imports.dart';

enum SpeedUnits {
  mS,
  kts,
  kmH,
  mpH,
}

enum DistanceUnits {
  km,
  mi,
  M,
}

enum TemperatureUnits {
  C,
  F,
}

class UnitsSystem {
  late SpeedUnits speedUnits;
  late DistanceUnits distanceUnits;
  late TemperatureUnits temperatureUnits;
  UnitsSystem({
    required this.speedUnits,
    required this.distanceUnits,
    required this.temperatureUnits,
  });
  factory UnitsSystem.fromListString(List<String> json) => UnitsSystem(
        speedUnits: UnitsService.speedUnitsFromString(json[0]),
        distanceUnits: UnitsService.distanceUnitsFromString(json[1]),
        temperatureUnits: UnitsService.temperatureUnitsFromString(json[2]),
      );

  List<String> toListString() => [
        UnitsService.speedUnitsToString(speedUnits),
        UnitsService.distanceUnitsToString(distanceUnits),
        UnitsService.temperatureUnitsToString(temperatureUnits),
      ];
  static Future<UnitsSystem> loadFromSettings() async =>
      await SharedPreferences.getInstance().then((value) =>
          UnitsSystem.fromListString(
              value.getStringList('units_system') ?? ['km/h', 'km', '°C']));

  static Future<void> saveToSettings(List<String> input) async =>
      await SharedPreferences.getInstance()
          .then((pref) => pref.setStringList('units_system', input));
}

class UnitsService {
  ///SPEED
  static String speedUnitsToString(SpeedUnits input) {
    switch (input) {
      case SpeedUnits.mS:
        return 'm/s';
      case SpeedUnits.kts:
        return 'kts';
      case SpeedUnits.kmH:
        return 'km/h';
      case SpeedUnits.mpH:
        return 'mph';
    }
  }

  static SpeedUnits speedUnitsFromString(String input) {
    switch (input) {
      case 'm/s':
        return SpeedUnits.mS;
      case 'kts':
        return SpeedUnits.kts;
      case 'km/h':
        return SpeedUnits.kmH;
      case 'mph':
        return SpeedUnits.mpH;
      default:
        return SpeedUnits.kmH;
    }
  }

  static double speedUnitsConvertFromKTS(SpeedUnits unit, double knot) {
    switch (unit) {
      case SpeedUnits.mS:
        return knot * 0.51444444; // _GPS_MPS_PER_KNOT 0.51444444
      case SpeedUnits.kts:
        return knot;
      case SpeedUnits.kmH:
        return knot * 1.852; // _GPS_KMPH_PER_KNOT 1.852
      case SpeedUnits.mpH:
        return knot * 1.15077945; //_GPS_MPH_PER_KNOT 1.15077945
    }
  }

  ///TEMPERATURE
  static String temperatureUnitsToString(TemperatureUnits input) {
    switch (input) {
      case TemperatureUnits.C:
        return '°C';
      case TemperatureUnits.F:
        return '°F';
    }
  }

  static TemperatureUnits temperatureUnitsFromString(String input) {
    switch (input) {
      case '°C':
        return TemperatureUnits.C;
      case '°F':
        return TemperatureUnits.F;
      default:
        return TemperatureUnits.C;
    }
  }

  static double temperatureUnitsFromCELSIUS(
      TemperatureUnits input, double value) {
    switch (input) {
      case TemperatureUnits.C:
        return value;
      case TemperatureUnits.F:
        return (value * 9 / 5) + 32;
    }
  }

  ///DISTANCE
  static String distanceUnitsToString(DistanceUnits input) {
    switch (input) {
      case DistanceUnits.km:
        return 'km';
      case DistanceUnits.mi:
        return 'mi';
      case DistanceUnits.M:
        return 'M';
    }
  }

  static DistanceUnits distanceUnitsFromString(String input) {
    switch (input) {
      case 'km':
        return DistanceUnits.km;
      case 'mi':
        return DistanceUnits.mi;
      case 'M':
        return DistanceUnits.M;
      default:
        return DistanceUnits.km;
    }
  }

  static double distanceUnitsConvertFromMETER(
      DistanceUnits unit, double meter) {
    switch (unit) {
      case DistanceUnits.km:
        return meter * 0.001; // _GPS_KM_PER_METER 0.001
      case DistanceUnits.mi:
        return meter * 0.00062137112; // _GPS_MILES_PER_METER 0.00062137112
      case DistanceUnits.M:
        return meter * 0.0002; // #define _GPS_NAUTICAL_MILES_PER_METER 0.0002

    }
  }
}
