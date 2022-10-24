import 'imports.dart';

class DatabaseSession {
  DatabaseSession({required this.deviceID});
  final String deviceID;

  ///COLLECTIONS & DOCS
  late CollectionReference<Map<String, dynamic>> sessionCollection =
      FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceID)
          .collection('sessions');

  ///CRUD
  Future add({required Session session}) async {
    return await sessionCollection.doc(session.id).set({
      'info': {
        'name': session.info.name,
        'start': session.info.start,
        'end': session.info.end,
      },
      'devicePosition': {
        'x': session.devicePosition.x,
        'y': session.devicePosition.y,
        'z': session.devicePosition.z,
        'timestamp': 0,
      }
    });
  }

  static Future edit(
      {required String uid,
      required Session oldSession,
      required Session newSession}) async {
    //TODO edit session
  }

  ///SERIALIZATION
  static Session sessionFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>?> snapshot) {
    return Session(
      id: snapshot.id,
      info: SessionInfo(
        name: snapshot.data()?['info']['name'],
        start: snapshot.data()?['info']['start'].toDate(),
        end: snapshot.data()?['info']['end'].toDate(),
      ),
      devicePosition: DevicePosition(
        x: snapshot.data()?['devicePosition']?['x']?.toInt(),
        y: snapshot.data()?['devicePosition']?['y']?.toInt(),
        z: snapshot.data()?['devicePosition']?['z']?.toInt(),
      ),
    );
  }

  static List<Session> sessionsListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => sessionFromSnapshot(snapshot)).toList();

  ///STREAMS
  Stream<Session> stream({required String id}) =>
      sessionCollection.doc(id).snapshots().map(sessionFromSnapshot);

  Stream<List<Session>> get streamList =>
      sessionCollection.snapshots().map(sessionsListFromSnapshot);
}
