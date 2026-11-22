import 'package:debt_documentation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'features/auth/auth_bloc_test.dart' show testAuthBloc, unverified;

void main() {
  testWidgets('session without a user opens the Arabic sign-in page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        createAuthBloc: () => testAuthBloc(Stream.value(const Right(null))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
  });

  testWidgets('unverified users must confirm their email before proceeding', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        createAuthBloc: () =>
            testAuthBloc(Stream.value(const Right(unverified))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تأكيد البريد الإلكتروني'), findsOneWidget);
    expect(find.text('دفتر الديون والشراكات'), findsNothing);
    await tester.tap(find.text('تحققت من بريدي'));
    await tester.pumpAndSettle();

    expect(find.text('دفتر الديون والشراكات'), findsOneWidget);
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'), findsOneWidget);
  });
}
