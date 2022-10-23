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
  });

  final String uid;
  final Profile profile;
  final List<String> devices;
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
}
