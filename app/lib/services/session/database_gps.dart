import '../imports.dart';

class DatabaseGpsPosition {
  DatabaseGpsPosition({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> telemetryCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('gps_position');

  ///CRUD
  Future add(GpsPosition gps) async {
    return telemetryCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'latitude': gps.latLng.latitude,
      'longitude': gps.latLng.longitude,
      'speed': gps.speed,
    });
  }

  ///SERIALIZATION
  static GpsPosition gpsFromSnapshot(
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

  static List<GpsPosition> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => gpsFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<GpsPosition> stream({required String telemetryID}) =>
      telemetryCollection.doc(telemetryID).snapshots().map(gpsFromSnapshot);

  Stream<List<GpsPosition>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}

class DatabaseGpsNavigation {
  DatabaseGpsNavigation({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> telemetryCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('gps_navigation');

  ///CRUD
  Future add(GpsNavigation gps) async {
    return telemetryCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'altitude': gps.altitude,
      'course': gps.course,
      'satellites': gps.variation,
    });
  }

  ///SERIALIZATION
  static GpsNavigation gpsFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    bool available = snapshot.data()?['available'] ?? false;
    return GpsNavigation(
      timestamp: int.parse(snapshot.id),
      available: available,
      altitude:
          available ? snapshot.data()!['altitude']?.toDouble() ?? 0.0 : 0.0,
      course: available ? snapshot.data()!['course']?.toDouble() ?? 0.0 : 0.0,
      variation: available ? snapshot.data()!['satellites']?.toInt() ?? 0 : 0,
    );
  }

  static List<GpsNavigation> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => gpsFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<GpsNavigation> stream({required String telemetryID}) =>
      telemetryCollection.doc(telemetryID).snapshots().map(gpsFromSnapshot);

  Stream<List<GpsNavigation>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}
