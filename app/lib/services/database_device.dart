import 'imports.dart';

class DatabaseDevice {
  static CollectionReference<Map<String, dynamic>> deviceCollection =
      FirebaseFirestore.instance.collection('devices');

  Future register(
      {required String serialNumber,
      required String modelNumber,
      required String modelName,
      required String name,
      required String uid,
      required int frequency}) async {
    Map<String, dynamic> value = {
      'modelNumber': modelNumber,
      "modelName": modelName,
      'name': name,
      'uid': uid,
      "frequency": frequency,
    };
    await DatabaseUser.devicesCreateRemove(
        isCreate: true, uid: uid, id: serialNumber);

    return await deviceCollection.doc(serialNumber).set(value);
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
      case 'Mode.realtime':
        return Mode.realtime;
      case 'Mode.record':
        return Mode.record;
      case 'Mode.sync':
        return Mode.sync;
      default:
        return Mode.realtime;
    }
  }

  static Device deviceFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Device(
        serialNumber: snapshot.id,
        modelNumber: snapshot.data()?['modelNumber'] ?? '',
        modelName: snapshot.data()?['modelName'] ?? '',
        uid: snapshot.data()?['uid'] ?? '',
        name: snapshot.data()?['name'] ?? '',
        clock: snapshot.data()?['clock'] ?? 0,
        frequency: snapshot.data()?['frequency'] ?? 0,
        sdCardAvailable: snapshot.data()?['sdCardAvailable'] ?? false,
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
