import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required Stream<AuthResult<AuthUser?>> Function() watchSession,
    required this.signIn,
    required this.register,
    required this.sendVerification,
    required this.refreshSession,
    required this.resetPassword,
    required this.signOut,
  }) : super(const AuthState()) {
    on<WatchSession>((event, emit) async {
      AppLogger.log('AuthBloc.WatchSession');
      await emit.forEach(
        watchSession(),
        onData: (result) => result.match(
          _failed,
          (user) => AuthState(
            sessionReady: true,
            user: user,
            status: state.busy
                ? AuthStatus.loading
                : user == null
                ? AuthStatus.empty
                : AuthStatus.loaded,
          ),
        ),
        onError: (error, stackTrace) => _failed(AuthFailure.unexpected),
      );
    });
    on<AuthAction>(_handleAction);
  }

  final Future<AuthResult<Unit>> Function(String, String) signIn;
  final Future<AuthResult<Unit>> Function(String, String) register;
  final Future<AuthResult<Unit>> Function() sendVerification;
  final Future<AuthResult<AuthUser?>> Function() refreshSession;
  final Future<AuthResult<Unit>> Function(String) resetPassword;
  final Future<AuthResult<Unit>> Function() signOut;
  bool _actionInProgress = false;

  Future<void> _handleAction(AuthAction event, Emitter<AuthState> emit) async {
    AppLogger.log('AuthBloc.${event.runtimeType}');
    if (_actionInProgress || !state.sessionReady) return;
    _actionInProgress = true;
    emit(
      AuthState(
        sessionReady: true,
        user: state.user,
        status: AuthStatus.loading,
      ),
    );
    try {
      if (event is RefreshSession) {
        final result = await refreshSession();
        emit(
          result.match(
            _failed,
            (user) => AuthState(
              sessionReady: true,
              user: user,
              status: user == null ? AuthStatus.empty : AuthStatus.loaded,
              notice: user?.emailVerified == false
                  ? AuthNotice.verificationPending
                  : null,
            ),
          ),
        );
        return;
      }

      AuthNotice? notice;
      final AuthResult<Unit> result;
      switch (event) {
        case SignIn(:final email, :final password):
          result = await signIn(email, password);
        case Register(:final email, :final password):
          final registration = await register(email, password);
          result = await registration.match(
            (failure) async => Left(failure),
            (_) => sendVerification(),
          );
          notice = AuthNotice.verificationSent;
        case SendVerification():
          result = await sendVerification();
          notice = AuthNotice.verificationSent;
        case ResetPassword(:final email):
          result = await resetPassword(email);
          notice = AuthNotice.passwordReset;
        case SignOut():
          result = await signOut();
        case RefreshSession():
          return;
      }
      emit(
        result.match(
          _failed,
          (_) => AuthState(
            sessionReady: true,
            user: event is SignOut ? null : state.user,
            status: event is SignOut || state.user == null
                ? AuthStatus.empty
                : AuthStatus.loaded,
            notice: notice,
          ),
        ),
      );
    } finally {
      _actionInProgress = false;
    }
  }

  AuthState _failed(AuthFailure failure) => AuthState(
    sessionReady: state.sessionReady,
    user: state.user,
    status: failure == AuthFailure.offline
        ? AuthStatus.offline
        : AuthStatus.error,
    failure: failure,
  );
}
