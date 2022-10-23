import '../imports.dart';

class DatabaseService {
  DatabaseService({required this.deviceID, required this.sessionID});
  final String deviceID;
  final String sessionID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> serviceCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions')
          .doc(sessionID)
          .collection('services');

  ///CRUD
  Future add(Service service) async {
    return serviceCollection.doc('${service.timestamp}').set({
      'battery': {
        'value': service.battery.value,
        'timestamp': service.battery.timestamp,
      },
      'temperature': {
        'value': service.temperature.value,
        'timestamp': service.temperature.timestamp,
      }
    });
  }

  ///SERIALIZATION
  static Service serviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Service(
      timestamp: int.parse(snapshot.id),
      battery: MonoDimensionalValueInt(
        value: snapshot.data()?['battery']?['value'] ?? 0,
        timestamp: snapshot.data()?['battery']?['timestamp'] ?? 0,
      ),
      temperature: MonoDimensionalValueDouble(
        value: snapshot.data()?['temperature']?['value'] ?? 0,
        timestamp: snapshot.data()?['temperature']?['timestamp'] ?? 0,
      ),
    );
  }

  static List<Service> servicesListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => serviceFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Service> singleTelemetry({required String telemetryID}) =>
      serviceCollection.doc(telemetryID).snapshots().map(serviceFromSnapshot);

  Stream<List<Service>> telemetries({required Session session}) =>
      serviceCollection.snapshots().map(servicesListFromSnapshot);
}
