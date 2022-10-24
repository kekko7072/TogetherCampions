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
  Future add(Gps gps) async {
    return telemetryCollection.doc('${gps.timestamp}').set({
      'available': gps.available,
      'latitude': gps.latLng.latitude,
      'longitude': gps.latLng.longitude,
      'altitude': gps.altitude,
      'speed': gps.speed,
      'course': gps.course,
      'satellites': gps.variation,
    });
  }

  ///SERIALIZATION
  static Gps gpsFromSnapshot(DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    bool available = snapshot.data()?['available'] ?? false;
    return Gps(
      timestamp: int.parse(snapshot.id),
      available: available,
      latLng: MapLatLng(available ? snapshot.data()!['latitude'] : 0.0,
          available ? snapshot.data()!['longitude'] : 0.0),
      altitude:
          available ? snapshot.data()!['altitude']?.toDouble() ?? 0.0 : 0.0,
      speed: available ? snapshot.data()!['speed']?.toDouble() ?? 0.0 : 0.0,
      course: available ? snapshot.data()!['course']?.toDouble() ?? 0.0 : 0.0,
      variation: available ? snapshot.data()!['satellites']?.toInt() ?? 0 : 0,
    );
  }

  static List<Gps> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => gpsFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Gps> stream({required String telemetryID}) =>
      telemetryCollection.doc(telemetryID).snapshots().map(gpsFromSnapshot);

  Stream<List<Gps>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}
