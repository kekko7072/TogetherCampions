import 'imports.dart';

class DatabaseDevice {
  static CollectionReference<Map<String, dynamic>> deviceCollection =
      FirebaseFirestore.instance.collection('devices');

  Future register({
    required String serialNumber,
    required String modelNumber,
    required String name,
    required String uid,
    required DevicePosition devicePosition,
  }) async {
    Map<String, dynamic> value = {
      'modelNumber': modelNumber,
      'name': name,
      'uid': uid,
      'devicePosition': {
        'x': devicePosition.x,
        'y': devicePosition.y,
        'z': devicePosition.z,
      }
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
      uid: snapshot.data()?['uid'] ?? '',
      name: snapshot.data()?['name'] ?? '',
      software: Software(
        name: snapshot.data()?['software']?['name'] ?? '',
        version: snapshot.data()?['software']?['version'] ?? '',
      ),
      devicePosition: DevicePosition(
        x: snapshot.data()?['devicePosition']?['x']?.toInt(),
        y: snapshot.data()?['devicePosition']?['y']?.toInt(),
        z: snapshot.data()?['devicePosition']?['z']?.toInt(),
      ),
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
