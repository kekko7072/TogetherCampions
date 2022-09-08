import 'package:app/services/imports.dart';

class CurrentUser {
  final String? uid;

  CurrentUser({
    this.uid,
  });
}

class UserData {
  UserData({
    required this.uid,
    required this.profile,
    required this.devices,
    required this.sessions,
  });

  final String uid;
  final Profile profile;
  final List<String> devices;
  final List<Session> sessions;
}

class Profile {
  Profile({
    required this.name,
    required this.surname,
    required this.email,
  });

  final String name;
  final String surname;
  final String email;

  ///ETCC...
}

class Session {
  Session({
    required this.name,
    required this.start,
    required this.end,
    required this.deviceID,
  });
  final String name;
  final DateTime start;
  final DateTime end;
  final String deviceID;
}
