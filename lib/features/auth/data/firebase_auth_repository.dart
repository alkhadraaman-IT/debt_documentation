import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'firebase_auth_source.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._source);

  final FirebaseAuthSource _source;

  @override
  Stream<AuthResult<AuthUser?>> watchSession() async* {
    try {
      await for (final user in _source.watchSession()) {
        yield Right(user);
      }
    } on FirebaseAuthException catch (error) {
      yield Left(_failure(error));
    } on Exception {
      yield const Left(AuthFailure.unexpected);
    }
  }

  @override
  Future<AuthResult<Unit>> signIn(String email, String password) =>
      _attempt(() async {
        await _source.signIn(email, password);
        return unit;
      });

  @override
  Future<AuthResult<Unit>> register(String email, String password) =>
      _attempt(() async {
        await _source.register(email, password);
        return unit;
      });

  @override
  Future<AuthResult<Unit>> sendVerification() => _attempt(() async {
    await _source.sendVerification();
    return unit;
  });

  @override
  Future<AuthResult<AuthUser?>> refreshSession() =>
      _attempt(_source.refreshSession);

  @override
  Future<AuthResult<Unit>> resetPassword(String email) => _attempt(() async {
    try {
      await _source.resetPassword(email);
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found') rethrow;
    }
    return unit;
  });

  @override
  Future<AuthResult<Unit>> signOut() => _attempt(() async {
    await _source.signOut();
    return unit;
  });

  Future<AuthResult<T>> _attempt<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on FirebaseAuthException catch (error) {
      return Left(_failure(error));
    } on Exception {
      return const Left(AuthFailure.unexpected);
    }
  }

  AuthFailure _failure(FirebaseAuthException error) => switch (error.code) {
    'network-request-failed' => AuthFailure.offline,
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' ||
    'user-disabled' => AuthFailure.invalidCredentials,
    'invalid-email' => AuthFailure.invalidEmail,
    'email-already-in-use' => AuthFailure.emailInUse,
    'weak-password' => AuthFailure.weakPassword,
    'too-many-requests' => AuthFailure.rateLimited,
    'no-current-user' || 'user-token-expired' => AuthFailure.sessionExpired,
    _ => AuthFailure.unexpected,
  };
}
