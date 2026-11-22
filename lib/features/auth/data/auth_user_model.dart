import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.emailVerified,
  });

  factory AuthUserModel.fromFirebase(User user) => AuthUserModel(
    id: user.uid,
    email: user.email ?? '',
    emailVerified: user.emailVerified,
  );
}
