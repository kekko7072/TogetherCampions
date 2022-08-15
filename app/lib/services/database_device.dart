import 'imports.dart';

class DatabaseDevice {
  static CollectionReference<Map<String, dynamic>> deviceCollection =
      FirebaseFirestore.instance.collection('devices');

  Future create({required UserData userData}) async {
    Map<String, dynamic> value = {
      'sessions': null,
    };
    return await deviceCollection.doc(userData.uid).set(value);
  }

  ///SESSION
  Future sessionCreateRemove(
      {required bool isCreate,
      required String uid,
      required Session session}) async {
    return await deviceCollection.doc(uid).update({
      'sessions': isCreate
          ? FieldValue.arrayUnion([
              {
                'name': session.name,
                'start': session.start,
                'end': session.end,
              }
            ])
          : FieldValue.arrayRemove([
              {
                'name': session.name,
                'start': session.start,
                'end': session.end,
              }
            ])
    });
  }

  Future sessionEdit(
      {required String uid,
      required Session oldSession,
      required Session newSession}) async {
    await deviceCollection.doc(uid).update({
      'sessions': FieldValue.arrayRemove([
        {
          'name': oldSession.name,
          'start': oldSession.start,
          'end': oldSession.end,
        },
      ]),
    });
    return await deviceCollection.doc(uid).update({
      'sessions': FieldValue.arrayUnion([
        {
          'name': newSession.name,
          'start': newSession.start,
          'end': newSession.end,
        },
      ]),
    });
  }

  ///SERIALIZATION
  static Device deviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Device(
      id: snapshot.id,
      uid: snapshot.data()?['uid'] ?? '',
      name: snapshot.data()?['name'] ?? '',
      clock: snapshot.data()?['clock'] ?? 0,
      frequency: snapshot.data()?['frequency'] ?? 0,
    );
  }

  List<Device> userDataListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => deviceFromSnapshot(snapshot)).toList();

  Stream<Device> device({required String id}) {
    return deviceCollection.doc(id).snapshots().map(deviceFromSnapshot);
  }
}
