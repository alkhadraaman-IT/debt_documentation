sealed class AuthEvent {
  const AuthEvent();
}

final class WatchSession extends AuthEvent {
  const WatchSession();
}

sealed class AuthAction extends AuthEvent {
  const AuthAction();
}

final class SignIn extends AuthAction {
  const SignIn(this.email, this.password);
  final String email;
  final String password;
}

final class Register extends AuthAction {
  const Register(this.email, this.password);
  final String email;
  final String password;
}

final class ResetPassword extends AuthAction {
  const ResetPassword(this.email);
  final String email;
}

final class SendVerification extends AuthAction {
  const SendVerification();
}

final class RefreshSession extends AuthAction {
  const RefreshSession();
}

final class SignOut extends AuthAction {
  const SignOut();
}
