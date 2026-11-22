import 'dart:async';

import 'package:debt_documentation/features/auth/domain/auth_repository.dart';
import 'package:debt_documentation/features/auth/domain/auth_user.dart';
import 'package:debt_documentation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:debt_documentation/features/auth/presentation/bloc/auth_event.dart';
import 'package:debt_documentation/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

const unverified = AuthUser(
  id: '1',
  email: 'person@example.com',
  emailVerified: false,
);

const verified = AuthUser(
  id: '1',
  email: 'person@example.com',
  emailVerified: true,
);

AuthBloc testAuthBloc(
  Stream<AuthResult<AuthUser?>> session, {
  Future<AuthResult<Unit>> Function(String, String)? register,
  Future<AuthResult<Unit>> Function()? sendVerification,
  Future<AuthResult<AuthUser?>> Function()? refreshSession,
}) => AuthBloc(
  watchSession: () => session,
  signIn: (_, _) async => const Right(unit),
  register: register ?? (_, _) async => const Right(unit),
  sendVerification: sendVerification ?? () async => const Right(unit),
  refreshSession: refreshSession ?? () async => const Right(verified),
  resetPassword: (_) async => const Right(unit),
  signOut: () async => const Right(unit),
);

Future<AuthState> dispatch(
  AuthBloc bloc,
  AuthEvent event,
  bool Function(AuthState) matches,
) {
  final result = bloc.stream.firstWhere(matches);
  bloc.add(event);
  return result;
}

void main() {
  test('restores the session, refreshes verification, and signs out', () async {
    final bloc = testAuthBloc(Stream.value(const Right(unverified)));
    addTearDown(bloc.close);

    final restored = await dispatch(
      bloc,
      const WatchSession(),
      (state) => state.sessionReady,
    );
    expect(restored.user, unverified);

    final refreshed = await dispatch(
      bloc,
      const RefreshSession(),
      (state) => state.user == verified,
    );
    expect(refreshed.status, AuthStatus.loaded);

    final signedOut = await dispatch(
      bloc,
      const SignOut(),
      (state) => state.status == AuthStatus.empty,
    );
    expect(signedOut.user, isNull);
  });

  test('keeps a newly created session when verification email fails', () async {
    final session = StreamController<AuthResult<AuthUser?>>();
    final bloc = testAuthBloc(
      session.stream,
      register: (_, _) async {
        session.add(const Right(unverified));
        return const Right(unit);
      },
      sendVerification: () async => const Left(AuthFailure.offline),
    );
    addTearDown(() async {
      await bloc.close();
      await session.close();
    });

    final ready = dispatch(
      bloc,
      const WatchSession(),
      (state) => state.sessionReady,
    );
    session.add(const Right(null));
    await ready;

    final failed = await dispatch(
      bloc,
      const Register('person@example.com', 'password'),
      (state) => state.status == AuthStatus.offline,
    );
    expect(failed.user, unverified);
    expect(failed.failure, AuthFailure.offline);
  });
}
