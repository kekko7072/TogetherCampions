import '../imports.dart';

class DatabaseGpsPosition {
  DatabaseGpsPosition({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> gpsPositionCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('gps_position');

  ///CRUD
  Future add(GpsPosition gps) async {
    return gpsPositionCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'latitude': gps.latLng.latitude,
      'longitude': gps.latLng.longitude,
      'speed': gps.speed,
    });
  }

  ///SERIALIZATION
  static GpsPosition gpsPositionFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    bool available = snapshot.data()?['available'] ?? false;
    return GpsPosition(
      timestamp: int.parse(snapshot.id),
      available: available,
      latLng: MapLatLng(available ? snapshot.data()!['latitude'] : 0.0,
          available ? snapshot.data()!['longitude'] : 0.0),
      speed: available ? snapshot.data()!['speed']?.toDouble() ?? 0.0 : 0.0,
    );
  }

  static List<GpsPosition> gpsPositionListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs
          .map((snapshot) => gpsPositionFromSnapshot(snapshot))
          .toList();

  ///STREAMS
  Stream<GpsPosition> stream({required String telemetryID}) =>
      gpsPositionCollection
          .doc(telemetryID)
          .snapshots()
          .map(gpsPositionFromSnapshot);

  Stream<List<GpsPosition>> get streamList =>
      gpsPositionCollection.snapshots().map(gpsPositionListFromSnapshot);
}

class DatabaseGpsNavigation {
  DatabaseGpsNavigation({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> gpsNavigationCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('gps_navigation');

  ///CRUD
  Future add(GpsNavigation gps) async {
    return gpsNavigationCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'altitude': gps.altitude,
      'course': gps.course,
      'variation': gps.variation,
    });
  }

  ///SERIALIZATION
  static GpsNavigation gpsNavigationFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    bool available = snapshot.data()?['available'] ?? false;
    return GpsNavigation(
      timestamp: int.parse(snapshot.id),
      available: available,
      altitude:
          available ? snapshot.data()!['altitude']?.toDouble() ?? 0.0 : 0.0,
      course: available ? snapshot.data()!['course']?.toDouble() ?? 0.0 : 0.0,
      variation:
          available ? snapshot.data()!['satellites']?.toDouble() ?? 0 : 0,
    );
  }

  static List<GpsNavigation> gpsNavigationListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs
          .map((snapshot) => gpsNavigationFromSnapshot(snapshot))
          .toList();

  ///STREAMS
  Stream<GpsNavigation> stream({required String telemetryID}) =>
      gpsNavigationCollection
          .doc(telemetryID)
          .snapshots()
          .map(gpsNavigationFromSnapshot);

  Stream<List<GpsNavigation>> get streamList =>
      gpsNavigationCollection.snapshots().map(gpsNavigationListFromSnapshot);
}
