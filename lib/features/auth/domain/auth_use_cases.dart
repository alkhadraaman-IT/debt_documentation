import 'package:fpdart/fpdart.dart';

import '../../../core/utils/app_logger.dart';
import 'auth_repository.dart';
import 'auth_user.dart';

Stream<AuthResult<AuthUser?>> watchSessionUseCase(AuthRepository repository) {
  AppLogger.log('🚀 Executing: WatchSessionUseCase');
  return repository.watchSession();
}

Future<AuthResult<Unit>> signInUseCase(
  AuthRepository repository,
  String email,
  String password,
) {
  AppLogger.log('🚀 Executing: SignInUseCase');
  return repository.signIn(email.trim(), password);
}

Future<AuthResult<Unit>> registerUseCase(
  AuthRepository repository,
  String email,
  String password,
) {
  AppLogger.log('🚀 Executing: RegisterUseCase');
  return repository.register(email.trim(), password);
}

Future<AuthResult<Unit>> sendVerificationUseCase(AuthRepository repository) {
  AppLogger.log('🚀 Executing: SendVerificationUseCase');
  return repository.sendVerification();
}

Future<AuthResult<AuthUser?>> refreshSessionUseCase(AuthRepository repository) {
  AppLogger.log('🚀 Executing: RefreshSessionUseCase');
  return repository.refreshSession();
}

Future<AuthResult<Unit>> resetPasswordUseCase(
  AuthRepository repository,
  String email,
) {
  AppLogger.log('🚀 Executing: ResetPasswordUseCase');
  return repository.resetPassword(email.trim());
}

Future<AuthResult<Unit>> signOutUseCase(AuthRepository repository) {
  AppLogger.log('🚀 Executing: SignOutUseCase');
  return repository.signOut();
}
