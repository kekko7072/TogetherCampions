import 'imports.dart';

class DatabaseDevice {
  static CollectionReference<Map<String, dynamic>> deviceCollection =
      FirebaseFirestore.instance.collection('devices');

  Future register({
    required String serialNumber,
    required String modelNumber,
    required String modelName,
    required String name,
    required String uid,
  }) async {
    Map<String, dynamic> value = {
      'modelNumber': modelNumber,
      "modelName": modelName,
      'name': name,
      'uid': uid,
    };
    await DatabaseUser.devicesCreateRemove(
        isCreate: true, uid: uid, id: serialNumber);

    return await deviceCollection.doc(serialNumber).set(value);
  }

  Future delete({required String id, required String uid}) async {
    await DatabaseUser.devicesCreateRemove(isCreate: false, uid: uid, id: id);

    return await deviceCollection.doc(id).delete();
  }

  ///SERIALIZATION

  static Device deviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Device(
        serialNumber: snapshot.id,
        modelNumber: snapshot.data()?['modelNumber'] ?? '',
        modelName: snapshot.data()?['modelName'] ?? '',
        uid: snapshot.data()?['uid'] ?? '',
        name: snapshot.data()?['name'] ?? '',
        software: Software(
          name: snapshot.data()?['software']?['name'] ?? '',
          version: snapshot.data()?['software']?['version'] ?? '',
        ));
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
