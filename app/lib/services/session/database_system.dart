import '../imports.dart';

class DatabaseSystem {
  DatabaseSystem({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('devices')
      .doc(deviceID)
      .collection('sessions')
      .doc(sessionID)
      .collection('services');

  ///CRUD
  Future add(System system) async {
    return collection.doc('${system.timestamp}').set({
      'battery': system.battery,
      'temperature': system.temperature,
    });
  }

  ///SERIALIZATION
  static System serviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return System(
      timestamp: int.parse(snapshot.id),
      battery: snapshot.data()?['battery'] ?? 0,
      temperature: snapshot.data()?['temperature'] ?? 0.0,
    );
  }

  static List<System> servicesListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<System> value =
        snapshot.docs.map((snapshot) => serviceFromSnapshot(snapshot)).toList();

    value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return value;
  }

  ///STREAMS
  Stream<System> singleTelemetry({required String telemetryID}) =>
      collection.doc(telemetryID).snapshots().map(serviceFromSnapshot);

  Stream<List<System>> telemetries({required Session session}) =>
      collection.snapshots().map(servicesListFromSnapshot);
}
