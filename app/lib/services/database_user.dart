import 'imports.dart';

class DatabaseUser {
  static CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');

  static Future createEdit(
      {required bool isEdit, required UserData userData}) async {
    Map<String, dynamic> value = {
      'profile': {
        'name': userData.profile.name,
        'surname': userData.profile.surname,
        'email': userData.profile.email,
      },
      'devices': userData.devices,
    };
    return isEdit
        ? await userCollection.doc(userData.uid).update(value)
        : await userCollection.doc(userData.uid).set(value);
  }

  ///DEVICES
  static Future devicesCreateRemove(
      {required bool isCreate, required String uid, required String id}) async {
    return await userCollection.doc(uid).update({
      'devices':
          isCreate ? FieldValue.arrayUnion([id]) : FieldValue.arrayRemove([id])
    });
  }

  ///SESSION
  static Future sessionCreateRemove(
      {required bool isCreate,
      required String uid,
      required String sessionID}) async {
    return await userCollection.doc(uid).update({
      'sessions': isCreate
          ? FieldValue.arrayUnion([sessionID])
          : FieldValue.arrayRemove([sessionID])
    });
  }

  ///SERIALIZATION
  static UserData userDataFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
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
    );
  }

  static List<UserData> userDataListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => userDataFromSnapshot(snapshot)).toList();

  static Stream<UserData> userData({required String uid}) {
    return userCollection.doc(uid).snapshots().map(userDataFromSnapshot);
  }
}
