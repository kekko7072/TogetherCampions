import '../imports.dart';

class DatabaseGps {
  DatabaseGps({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> telemetryCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('gps');

  ///CRUD
  Future add(GPS gps) async {
    return telemetryCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'latitude': gps.latLng.latitude,
      'longitude': gps.latLng.longitude,
      'altitude': gps.altitude,
      'speed': gps.speed,
      'course': gps.course,
      'satellites': gps.satellites,
    });
  }

  ///SERIALIZATION
  static GPS gpsFromSnapshot(DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    bool available = snapshot.data()?['available'] ?? false;
    return GPS(
      timestamp: int.parse(snapshot.id),
      available: available,
      latLng: MapLatLng(available ? snapshot.data()!['latitude'] : 0.0,
          available ? snapshot.data()!['longitude'] : 0.0),
      altitude:
          available ? snapshot.data()!['altitude']?.toDouble() ?? 0.0 : 0.0,
      speed: available ? snapshot.data()!['speed']?.toDouble() ?? 0.0 : 0.0,
      course: available ? snapshot.data()!['course']?.toDouble() ?? 0.0 : 0.0,
      satellites: available ? snapshot.data()!['satellites']?.toInt() ?? 0 : 0,
    );
  }

  static List<GPS> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => gpsFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<GPS> stream({required String telemetryID}) =>
      telemetryCollection.doc(telemetryID).snapshots().map(gpsFromSnapshot);

  Stream<List<GPS>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}
