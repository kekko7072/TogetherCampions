import 'imports.dart';

class DatabaseUser {
  DatabaseUser();

  static CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');

  Future create({required UserData userData}) async {
    Map<String, dynamic> value = {
      'sessions': null,
    };
    return await userCollection.doc(userData.uid).set(value);
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
