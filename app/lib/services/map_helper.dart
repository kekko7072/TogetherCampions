import 'imports.dart';

class MapHelper {
  static MapLatLng findCenter(MapLatLng from, MapLatLng to) {
    //Find the center of the two points
    double lat1 = CalculationService.toRadian(from.latitude);
    double lng1 = CalculationService.toRadian(from.longitude);
    double lat2 = CalculationService.toRadian(to.latitude);
    double lng2 = CalculationService.toRadian(to.longitude);

    double dLong = lng2 - lng1;

    double bx = cos(lat2) * cos(dLong);
    double by = cos(lat2) * sin(dLong);

    double latMidway = CalculationService.toDegrees(atan2(sin(lat1) + sin(lat2),
        sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by)));
    double lngMidway =
        CalculationService.toDegrees(lng1 + atan2(by, cos(lat1) + bx));

    return MapLatLng(latMidway, lngMidway);
  }

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
    double lat1 = CalculationService.toRadian(from.latitude);
    double lng1 = CalculationService.toRadian(from.longitude);
    double lat2 = CalculationService.toRadian(to.latitude);
    double lng2 = CalculationService.toRadian(to.longitude);

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

    if (distance < 2.5) {
      if (isPreview) {
        zoom = 15 - 2 * distance;
      } else {
        zoom = 15 - 1.35 * distance;
      }
    } else if (distance < 5) {
      if (isPreview) {
        zoom = 16 - 1.5 * distance;
      } else {
        zoom = 16 - 1.35 * distance;
      }
    } else if (distance < 10) {
      if (isPreview) {
        zoom = 18.5 - 1.5 * distance;
      } else {
        zoom = 18.5 - 1.35 * distance;
      }
    } else if (distance < 20) {
      if (isPreview) {
        zoom = 12.5;
      } else {
        zoom = 15.5;
      }
    } else if (distance < 30) {
      if (isPreview) {
        zoom = 9.5;
      } else {
        zoom = 11.5;
      }
    } else if (distance < 50) {
      if (isPreview) {
        zoom = 8.5;
      } else {
        zoom = 10.5;
      }
    } else if (distance < 100) {
      if (isPreview) {
        zoom = 6;
      } else {
        zoom = 9;
      }
    } else {
      if (isPreview) {
        zoom = 5;
      } else {
        zoom = 8;
      }
    }

    return MapZoomPanBehavior(
      zoomLevel: zoom,
      minZoomLevel: 3,
      maxZoomLevel: 30,
      enableMouseWheelZooming: true,
      enableDoubleTapZooming: true,
      focalLatLng: findCenter(start, end),
      showToolbar: !isPreview,
      toolbarSettings: const MapToolbarSettings(
          direction: Axis.horizontal,
          position: MapToolbarPosition.topRight,
          iconColor: Colors.black),
    );
  }
}
