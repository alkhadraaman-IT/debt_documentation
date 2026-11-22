import 'package:equatable/equatable.dart';

import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

enum AuthStatus { initial, loading, loaded, empty, error, offline }

enum AuthNotice { verificationSent, verificationPending, passwordReset }

class AuthState extends Equatable {
  const AuthState({
    this.sessionReady = false,
    this.user,
    this.status = AuthStatus.initial,
    this.failure,
    this.notice,
  });

  final bool sessionReady;
  final AuthUser? user;
  final AuthStatus status;
  final AuthFailure? failure;
  final AuthNotice? notice;

  bool get busy => status == AuthStatus.loading;

  @override
  List<Object?> get props => [sessionReady, user, status, failure, notice];
}
