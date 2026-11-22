import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/firebase_auth_source.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/domain/auth_use_cases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

GetIt configureDependencies(FirebaseAuth firebaseAuth) {
  final dependencies = GetIt.asNewInstance();
  dependencies
    ..registerSingleton(firebaseAuth)
    ..registerLazySingleton(() => FirebaseAuthSource(dependencies()))
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(dependencies()),
    )
    ..registerFactory(() {
      final repository = dependencies<AuthRepository>();
      return AuthBloc(
        watchSession: () => watchSessionUseCase(repository),
        signIn: (email, password) => signInUseCase(repository, email, password),
        register: (email, password) =>
            registerUseCase(repository, email, password),
        sendVerification: () => sendVerificationUseCase(repository),
        refreshSession: () => refreshSessionUseCase(repository),
        resetPassword: (email) => resetPasswordUseCase(repository, email),
        signOut: () => signOutUseCase(repository),
      );
    });
  return dependencies;
}
