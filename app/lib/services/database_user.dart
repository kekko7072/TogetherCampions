import 'imports.dart';

class DatabaseUser {
  DatabaseUser();

  static CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');

  Future createEdit({required bool isEdit, required UserData userData}) async {
    Map<String, dynamic> value = {
      'profile': {
        'name': userData.profile.name,
        'surname': userData.profile.surname,
        'email': userData.profile.email,
      },
      'devices': userData.devices,
      'sessions': isEdit ? userData.sessions : [],
    };
    return isEdit
        ? await userCollection.doc(userData.uid).update(value)
        : await userCollection.doc(userData.uid).set(value);
  }

  ///DEVICES
  Future devicesCreateRemove(
      {required bool isCreate, required String uid, required String id}) async {
    return await userCollection.doc(uid).update({
      'devices':
          isCreate ? FieldValue.arrayUnion([id]) : FieldValue.arrayRemove([id])
    });
  }

  ///SESSION
  Future sessionCreateRemove(
      {required bool isCreate,
      required String uid,
      required Session session}) async {
    return await userCollection.doc(uid).update({
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
    await userCollection.doc(uid).update({
      'sessions': FieldValue.arrayRemove([
        {
          'name': oldSession.name,
          'start': oldSession.start,
          'end': oldSession.end,
        },
      ]),
    });
    return await userCollection.doc(uid).update({
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
  static UserData userDataFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    List<Session> sessions = [];
    int i = 0;
    for (i = 0; i < snapshot.data()?['sessions'].length; i++) {
      sessions.add(Session(
          name: snapshot.data()?['sessions'][i]['name'],
          start: snapshot.data()?['sessions'][i]['start'].toDate(),
          end: snapshot.data()?['sessions'][i]['end'].toDate()));
    }

    sessions.sort((a, b) => a.start.compareTo(b.start));

    return UserData(
      uid: snapshot.id,
      profile: Profile(
        name: snapshot.data()?['profile']?['name'] ?? '',
        surname: snapshot.data()?['profile']?['surname'] ?? '',
        email: snapshot.data()?['profile']?['email'] ?? '',
      ),
      devices: snapshot.data()?['devices'] != null
          ? (snapshot.data()?['devices'] as List)
              .map((item) => item as String)
              .toList()
          : [],
      sessions: sessions,
    );
  }

  List<UserData> userDataListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => userDataFromSnapshot(snapshot)).toList();

  Stream<UserData> userData({required String uid}) {
    return userCollection.doc(uid).snapshots().map(userDataFromSnapshot);
  }
}
