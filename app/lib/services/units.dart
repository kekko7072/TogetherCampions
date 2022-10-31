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
  nm,
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
  ///TODO CREATE CONVERSION OF EACH UNITS
  ///
  ///
  ///

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

  ///DISTANCE
  static String distanceUnitsToString(DistanceUnits input) {
    switch (input) {
      case DistanceUnits.km:
        return 'km';
      case DistanceUnits.mi:
        return 'mi';
      case DistanceUnits.nm:
        return 'NM';
    }
  }

  static DistanceUnits distanceUnitsFromString(String input) {
    switch (input) {
      case 'km':
        return DistanceUnits.km;
      case 'mi':
        return DistanceUnits.mi;
      case 'NM':
        return DistanceUnits.nm;
      default:
        return DistanceUnits.km;
    }
  }
}
