import 'imports.dart';

class DatabaseDevice {
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
  }

  Future delete({required String id, required String uid}) async {}
}
