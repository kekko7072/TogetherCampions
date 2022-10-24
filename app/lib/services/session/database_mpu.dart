import '../imports.dart';

class DatabaseMpu {
  DatabaseMpu({required this.deviceID, required this.sessionID});
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
  Future add(Mpu mpu) async {
    return telemetryCollection.doc('${mpu.timestamp}').set({
      'aX': mpu.aX,
      'aY': mpu.aY,
      'aZ': mpu.aZ,
      'gX': mpu.gX,
      'gY': mpu.gY,
      'gZ': mpu.gZ,
    });
  }

  ///SERIALIZATION
  static Mpu telemetryFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Mpu(
      timestamp: int.parse(snapshot.id),
      aX: snapshot.data()?['aX'] ?? 0,
      aY: snapshot.data()?['aY'] ?? 0,
      aZ: snapshot.data()?['aZ'] ?? 0,
      gX: snapshot.data()?['gX'] ?? 0,
      gY: snapshot.data()?['gY'] ?? 0,
      gZ: snapshot.data()?['gZ'] ?? 0,
    );
  }

  static List<Mpu> telemetriesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => telemetryFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Mpu> stream({required String telemetryID}) => telemetryCollection
      .doc(telemetryID)
      .snapshots()
      .map(telemetryFromSnapshot);

  Stream<List<Mpu>> get streamList =>
      telemetryCollection.snapshots().map(telemetriesListFromSnapshot);
}
