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
      }
    });
  }

  Future edit({required Session session}) async {
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
      }
    });
  }

  Future delete({required String id}) async {
    var systems = await DatabaseSystem(deviceID: deviceID, sessionID: id)
        .collection
        .get();
    for (var element in systems.docs) {
      await element.reference.delete();
    }
    var gpsPosition =
        await DatabaseGpsPosition(deviceID: deviceID, sessionID: id)
            .collection
            .get();
    for (var element in gpsPosition.docs) {
      await element.reference.delete();
    }
    var gpsNavigation =
        await DatabaseGpsNavigation(deviceID: deviceID, sessionID: id)
            .collection
            .get();
    for (var element in gpsNavigation.docs) {
      await element.reference.delete();
    }
    var accelerometer =
        await DatabaseAccelerometer(deviceID: deviceID, sessionID: id)
            .collection
            .get();
    for (var element in accelerometer.docs) {
      await element.reference.delete();
    }
    var gyroscope = await DatabaseGyroscope(deviceID: deviceID, sessionID: id)
        .collection
        .get();
    for (var element in gyroscope.docs) {
      await element.reference.delete();
    }
    return await sessionCollection.doc(id).delete();
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

  Stream<List<Session>> get streamList => sessionCollection
      .orderBy('info.start', descending: true)
      .snapshots()
      .map(sessionsListFromSnapshot);
}
