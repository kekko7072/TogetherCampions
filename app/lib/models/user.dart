import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  UserData({
    required this.devices,
  });

  final List<String> devices;
}
