import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/app_logger.dart';
import 'auth_user_model.dart';

class FirebaseAuthSource {
  const FirebaseAuthSource(this._auth);

  final FirebaseAuth _auth;

  Stream<AuthUserModel?> watchSession() =>
      _auth.authStateChanges().map(_toModel);

  Future<void> signIn(String email, String password) => _run(
    'signIn',
    () async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    },
  );

  Future<void> register(String email, String password) =>
      _run('register', () async {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      });

  Future<void> sendVerification() => _run('sendVerification', () async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    if (!user.emailVerified) {
      await _auth.setLanguageCode('ar');
      await user.sendEmailVerification();
    }
  });

  Future<AuthUserModel?> refreshSession() => _run('refreshSession', () async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      await user.reload();
      final current = _auth.currentUser;
      if (current?.uid != user.uid) return _toModel(current);
      if (current!.emailVerified) await current.getIdToken(true);
      return _toModel(current);
    } on FirebaseAuthException catch (error) {
      if (const {
        'user-disabled',
        'user-not-found',
        'user-token-expired',
      }.contains(error.code)) {
        await _auth.signOut();
      }
      rethrow;
    }
  });

  Future<void> resetPassword(String email) => _run('resetPassword', () async {
    await _auth.setLanguageCode('ar');
    await _auth.sendPasswordResetEmail(email: email);
  });

  Future<void> signOut() => _run('signOut', _auth.signOut);

  AuthUserModel? _toModel(User? user) =>
      user == null ? null : AuthUserModel.fromFirebase(user);

  Future<T> _run<T>(String operation, Future<T> Function() action) async {
    AppLogger.log('FirebaseAuth.$operation');
    try {
      final result = await action();
      AppLogger.log('FirebaseAuth.$operation succeeded');
      return result;
    } on FirebaseAuthException catch (error) {
      AppLogger.log('FirebaseAuth.$operation failed: ${error.code}');
      rethrow;
    }
  }
}
