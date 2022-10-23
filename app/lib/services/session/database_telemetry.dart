import '../imports.dart';

class DatabaseTelemetry {
  DatabaseTelemetry({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> telemetryCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('telemetries');

  ///CRUD
  Future add(Telemetry telemetry) async {
    return telemetryCollection.doc('${telemetry.timestamp}').set({
      'acceleration': {
        'x': telemetry.acceleration.x,
        'y': telemetry.acceleration.y,
        'z': telemetry.acceleration.z,
        'timestamp': telemetry.acceleration.timestamp,
      },
      'gyroscope': {
        'x': telemetry.gyroscope.x,
        'y': telemetry.gyroscope.y,
        'z': telemetry.gyroscope.z,
        'timestamp': telemetry.gyroscope.timestamp,
      },
    });
  }

  ///SERIALIZATION
  static Telemetry telemetryFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Telemetry(
      timestamp: int.parse(snapshot.id),
      acceleration: ThreeDimensionalValueInt(
        x: snapshot.data()?['acceleration']?['x'] ?? 0,
        y: snapshot.data()?['acceleration']?['y'] ?? 0,
        z: snapshot.data()?['acceleration']?['z'] ?? 0,
        timestamp: snapshot.data()?['acceleration']?['timestamp'] ?? 0,
      ),
      gyroscope: ThreeDimensionalValueInt(
        x: snapshot.data()?['gyroscope']?['x'] ?? 0,
        y: snapshot.data()?['gyroscope']?['y'] ?? 0,
        z: snapshot.data()?['gyroscope']?['z'] ?? 0,
        timestamp: snapshot.data()?['gyroscope']?['timestamp'] ?? 0,
      ),
    );
  }

  static List<Telemetry> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => telemetryFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Telemetry> stream({required String telemetryID}) => telemetryCollection
      .doc(telemetryID)
      .snapshots()
      .map(telemetryFromSnapshot);

  Stream<List<Telemetry>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}
