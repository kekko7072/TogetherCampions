import 'imports.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String error = '';

  CurrentUser? _userFromFirebase(User? user) {
    return CurrentUser(uid: user?.uid);
  }

  Stream<CurrentUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;

      UserData userData = UserData(
        uid: user.uid,
        sessions: [],
      );
      await DatabaseUser().create(userData: userData);

      return _userFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      error = e.message!;
      return null;
    } catch (e) {
      error = e.toString();
      return null;
    }
  }

  Future loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      error = e.toString();
      return null;
    }
  }
}
