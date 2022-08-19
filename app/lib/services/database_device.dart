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
        ? await deviceCollection.doc(device.serialNumber).update(value)
        : await deviceCollection.doc(device.serialNumber).set(value);
  }

  Future delete({required String id, required String uid}) async {
    await DatabaseUser.devicesCreateRemove(isCreate: false, uid: uid, id: id);

    return await deviceCollection.doc(id).delete();
  }

  Future editFrequency(
      {required String serialNumber, required int frequency}) async {
    return await deviceCollection.doc(serialNumber).update({
      'frequency': frequency,
    });
  }

  Future editMode({required String serialNumber, required Mode mode}) async {
    return await deviceCollection.doc(serialNumber).update({
      'mode': mode.toString(),
    });
  }

  ///SERIALIZATION
  static Mode modeParser(String snapshot) {
    switch (snapshot) {
      case 'Mode.cloud':
        return Mode.cloud;
      case 'Mode.sdCard':
        return Mode.sdCard;
      default:
        return Mode.cloud;
    }
  }

  static Device deviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Device(
        serialNumber: snapshot.id,
        modelNumber: snapshot.data()?['modelNumber'] ?? '',
        uid: snapshot.data()?['uid'] ?? '',
        name: snapshot.data()?['name'] ?? '',
        clock: snapshot.data()?['clock'] ?? 0,
        frequency: snapshot.data()?['frequency'] ?? 0,
        mode: modeParser(snapshot.data()?['mode'] ?? ''),
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
