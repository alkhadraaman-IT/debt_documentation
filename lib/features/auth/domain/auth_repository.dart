import 'package:fpdart/fpdart.dart';

import 'auth_user.dart';

enum AuthFailure {
  offline,
  invalidCredentials,
  invalidEmail,
  emailInUse,
  weakPassword,
  rateLimited,
  sessionExpired,
  unexpected,
}

typedef AuthResult<T> = Either<AuthFailure, T>;

abstract interface class AuthRepository {
  Stream<AuthResult<AuthUser?>> watchSession();
  Future<AuthResult<Unit>> signIn(String email, String password);
  Future<AuthResult<Unit>> register(String email, String password);
  Future<AuthResult<Unit>> sendVerification();
  Future<AuthResult<AuthUser?>> refreshSession();
  Future<AuthResult<Unit>> resetPassword(String email);
  Future<AuthResult<Unit>> signOut();
}
