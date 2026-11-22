import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_panel.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final bloc = context.read<AuthBloc>();
    return AuthPanel(
      title: 'تأكيد البريد الإلكتروني',
      children: [
        const Text('افتح رابط التأكيد في بريدك، ثم اضغط «تحققت من بريدي».'),
        if (state.user case final user?)
          Text(user.email, textDirection: TextDirection.ltr),
        AppButton(
          text: 'تحققت من بريدي',
          onPressed: state.busy ? null : () => bloc.add(const RefreshSession()),
        ),
        TextButton(
          onPressed: state.busy
              ? null
              : () => bloc.add(const SendVerification()),
          child: const Text('إعادة إرسال رابط التأكيد'),
        ),
        const SignOutButton(),
      ],
    );
  }
}

class SignedInPage extends StatelessWidget {
  const SignedInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthBloc bloc) => bloc.state.user?.email);
    return AuthPanel(
      title: AppConstants.name,
      children: [
        if (email != null) Text(email, textDirection: TextDirection.ltr),
        const SignOutButton(),
      ],
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthBloc bloc) => bloc.state.busy);
    return TextButton(
      onPressed: busy
          ? null
          : () => context.read<AuthBloc>().add(const SignOut()),
      child: const Text('تسجيل الخروج'),
    );
  }
}

class AuthStartupPage extends StatelessWidget {
  const AuthStartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final failure = context.select((AuthBloc bloc) => bloc.state.failure);
    return AuthPanel(
      title: AppConstants.name,
      children: [
        if (failure == null)
          const DelayedProgress(skeleton: true)
        else ...[
          const Text('تعذّر استعادة الجلسة. حاول مرة أخرى.'),
          AppButton(
            text: 'إعادة المحاولة',
            onPressed: () => context.read<AuthBloc>().add(const WatchSession()),
          ),
        ],
      ],
    );
  }
}
