import 'imports.dart';

class DatabaseDevice {
  static CollectionReference<Map<String, dynamic>> deviceCollection =
      FirebaseFirestore.instance.collection('devices');

  Future create({required bool isEdit, required Device device}) async {
    Map<String, dynamic> value = {
      'name': device.name,
      'uid': device.uid,
      'clock': device.clock,
      'frequency': device.frequency,
    };
    return isEdit
        ? await deviceCollection.doc(device.id).update(value)
        : await deviceCollection.doc(device.id).set(value);
  }

  Future delete({required String id, required String uid}) async {
    await DatabaseUser().devicesCreateRemove(isCreate: false, uid: uid, id: id);

    return await deviceCollection.doc(id).delete();
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

  List<Device> deviceListFromSnapshot(
          QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((snapshot) => deviceFromSnapshot(snapshot)).toList();

  Stream<Device> device({required String id}) {
    return deviceCollection.doc(id).snapshots().map(deviceFromSnapshot);
  }

  Stream<List<Device>> allDevices({required String uid}) {
    return deviceCollection
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(deviceListFromSnapshot);
  }
}
