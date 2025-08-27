import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _fa = FirebaseAuth.instance;

  Future<User?> signInAnonymously() async {
    final cred = await _fa.signInAnonymously();
    return cred.user;
  }

  Future<void> signOut() async {
    await _fa.signOut();
  }

  User? get currentUser => _fa.currentUser;
  bool get isLoggedIn => _fa.currentUser != null;
}
