import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/credentials_page.dart';
import '../../features/auth/presentation/pages/session_pages.dart';
import '../constants/app_constants.dart';

GoRouter createRouter(AuthBloc bloc, Listenable refresh) => GoRouter(
  refreshListenable: refresh,
  redirect: (context, state) {
    final path = state.matchedLocation;
    if (!bloc.state.sessionReady) {
      return path == AppConstants.startupPath ? null : AppConstants.startupPath;
    }
    final AuthUser? user = bloc.state.user;
    if (user == null) {
      return switch (path) {
        AppConstants.loginPath ||
        AppConstants.registerPath ||
        AppConstants.resetPath => null,
        _ => AppConstants.loginPath,
      };
    }
    final target = user.emailVerified
        ? AppConstants.homePath
        : AppConstants.verifyPath;
    return path == target ? null : target;
  },
  routes: [
    GoRoute(
      path: AppConstants.startupPath,
      builder: (context, state) => const AuthStartupPage(),
    ),
    GoRoute(
      path: AppConstants.homePath,
      builder: (context, state) => const SignedInPage(),
    ),
    GoRoute(
      path: AppConstants.verifyPath,
      builder: (context, state) => const VerifyEmailPage(),
    ),
    for (final (path, mode) in const [
      (AppConstants.loginPath, CredentialsMode.login),
      (AppConstants.registerPath, CredentialsMode.register),
      (AppConstants.resetPath, CredentialsMode.reset),
    ])
      GoRoute(
        path: path,
        builder: (context, state) => CredentialsPage(mode: mode),
      ),
  ],
);
