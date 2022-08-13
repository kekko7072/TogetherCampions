class CurrentUser {
  final String? uid;

  CurrentUser({
    this.uid,
  });
}

class UserData {
  UserData({
    required this.uid,
    required this.sessions,
  });

  final String uid;
  final List<Session> sessions;
}

class Session {
  Session({
    required this.name,
    required this.start,
    required this.end,
  });
  final String name;
  final DateTime start;
  final DateTime end;
}
