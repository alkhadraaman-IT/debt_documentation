import 'package:debt_documentation/features/auth/domain/auth_repository.dart';
import 'package:debt_documentation/features/auth/domain/auth_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('sign-in trims the email and preserves the password', () async {
    final repository = MockAuthRepository();
    const email = 'person@example.com';
    const password = ' pass word ';
    when(() => repository.signIn(email, password))
        .thenAnswer((_) async => const Right(unit));

    final result = await signInUseCase(repository, ' $email ', password);

    expect(result, const Right<AuthFailure, Unit>(unit));
    verify(() => repository.signIn(email, password)).called(1);
  });

  test('password recovery passes the repository failure through', () async {
    final repository = MockAuthRepository();
    const email = 'person@example.com';
    when(() => repository.resetPassword(email))
        .thenAnswer((_) async => const Left(AuthFailure.offline));

    final result = await resetPasswordUseCase(repository, ' $email ');

    expect(result, const Left<AuthFailure, Unit>(AuthFailure.offline));
  });
}
