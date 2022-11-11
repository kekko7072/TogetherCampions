/*import '../imports.dart';

class DatabaseAccelerometer {
  DatabaseAccelerometer({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('devices')
      .doc(deviceID)
      .collection('sessions')
      .doc(sessionID)
      .collection('accelerometer');

  ///CRUD
  Future add(Accelerometer mpu) async {
    return collection.doc('${mpu.timestamp}').set({
      'aX': mpu.aX,
      'aY': mpu.aY,
      'aZ': mpu.aZ,
    });
  }

  ///SERIALIZATION
  static Accelerometer telemetryFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Accelerometer(
      timestamp: int.parse(snapshot.id),
      aX: snapshot.data()?['aX'] ?? 0,
      aY: snapshot.data()?['aY'] ?? 0,
      aZ: snapshot.data()?['aZ'] ?? 0,
    );
  }

  static List<Accelerometer> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => telemetryFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Accelerometer> stream({required String telemetryID}) =>
      collection.doc(telemetryID).snapshots().map(telemetryFromSnapshot);

  Stream<List<Accelerometer>> get streamList =>
      collection.snapshots().map(telemetriesListFromSnapshot);
}

class DatabaseGyroscope {
  DatabaseGyroscope({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('devices')
      .doc(deviceID)
      .collection('sessions')
      .doc(sessionID)
      .collection('gyroscope');

  ///CRUD
  Future add(Gyroscope mpu) async {
    return collection.doc('${mpu.timestamp}').set({
      'gX': mpu.gX,
      'gY': mpu.gY,
      'gZ': mpu.gZ,
    });
  }

  ///SERIALIZATION
  static Gyroscope telemetryFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Gyroscope(
      timestamp: int.parse(snapshot.id),
      gX: snapshot.data()?['gX'] ?? 0,
      gY: snapshot.data()?['gY'] ?? 0,
      gZ: snapshot.data()?['gZ'] ?? 0,
    );
  }

  static List<Gyroscope> telemetriesListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<Gyroscope> value = snapshot.docs
        .map((snapshot) => telemetryFromSnapshot(snapshot))
        .toList();

    value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return value;
  }

  ///STREAMS
  Stream<Gyroscope> stream({required String telemetryID}) =>
      collection.doc(telemetryID).snapshots().map(telemetryFromSnapshot);

  Stream<List<Gyroscope>> get streamList =>
      collection.snapshots().map(telemetriesListFromSnapshot);
}
*/
