import 'imports.dart';

class DatabaseLog {
  DatabaseLog({required this.id});
  final String id;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> logCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(id)
          .collection('logs');

  Future delete() async {
    List<Log> allLogs = DatabaseLog.logListFromSnapshot(
        await DatabaseLog(id: id).logCollection.get());
    for (Log log in allLogs) {
      await logCollection.doc(log.id).delete();
    }
  }

  ///SERIALIZATION
  static Log logFromSnapshot(DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Log(
        id: snapshot.id,
        timestamp: snapshot.data()?['timestamp'] != null
            ? snapshot.data()!['timestamp'].toDate()
            : DateTime.now(),
        battery: snapshot.data()?['battery'].toDouble() ?? 0.0,
        gps: GPS(
          latLng: LatLng(
              '${snapshot.data()?['gps']?['latitude']}' != 'NaN'
                  ? snapshot.data()?['gps']?['latitude']?.toDouble() ?? 0.0
                  : 0.0,
              '${snapshot.data()?['gps']?['longitude']}' != 'NaN'
                  ? snapshot.data()?['gps']?['longitude']?.toDouble() ?? 0.0
                  : 0.0),
          altitude: '${snapshot.data()?['gps']?['altitude']}' != 'NaN'
              ? snapshot.data()?['gps']?['altitude']?.toDouble() ?? 0.0
              : 0.0,
          speed: '${snapshot.data()?['gps']?['speed']}' != 'NaN'
              ? snapshot.data()?['gps']?['speed']?.toDouble() ?? 0.0
              : 0.0,
          course: '${snapshot.data()?['gps']?['course']}' != 'NaN'
              ? snapshot.data()?['gps']?['course']?.toDouble() ?? 0.0
              : 0.0,
          satellites: '${snapshot.data()?['gps']?['satellites']}' != 'NaN'
              ? snapshot.data()?['gps']?['satellites']?.toInt() ?? 0
              : 0,
        ));
  }

  static List<Log> logListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => logFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Log> singleLog({required String id}) =>
      logCollection.doc(id).snapshots().map(logFromSnapshot);

  Stream<List<Log>> sessionLogs({required Session session}) => logCollection
      .where('timestamp',
          isLessThan: Timestamp.fromDate(session.end),
          isGreaterThan: Timestamp.fromDate(session.start))
      .snapshots()
      .map(logListFromSnapshot);

  Stream<List<Log>> get allLogs => logCollection
      .orderBy('timestamp', descending: false)
      .limitToLast(100)
      .snapshots()
      .map(logListFromSnapshot);

  Stream<List<Log>> get lastLog => logCollection
      .orderBy('timestamp', descending: false)
      .limitToLast(1)
      .snapshots()
      .map(logListFromSnapshot);
}
