import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_panel.dart';

enum CredentialsMode { login, register, reset }

class CredentialsPage extends StatefulWidget {
  const CredentialsPage({super.key, required this.mode});

  final CredentialsMode mode;

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.busy || !_form.currentState!.validate()) return;
    final email = _email.text;
    final password = _password.text;
    bloc.add(switch (widget.mode) {
      CredentialsMode.login => SignIn(email, password),
      CredentialsMode.register => Register(email, password),
      CredentialsMode.reset => ResetPassword(email),
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthBloc bloc) => bloc.state.busy);
    final mode = widget.mode;
    final isLogin = mode == CredentialsMode.login;
    final isReset = mode == CredentialsMode.reset;
    final title = switch (mode) {
      CredentialsMode.login => 'تسجيل الدخول',
      CredentialsMode.register => 'إنشاء حساب',
      CredentialsMode.reset => 'استعادة كلمة المرور',
    };
    return Form(
      key: _form,
      child: AutofillGroup(
        child: AuthPanel(
          title: title,
          children: [
            TextFormField(
              controller: _email,
              enabled: !busy,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              textInputAction: isReset
                  ? TextInputAction.done
                  : TextInputAction.next,
              onFieldSubmitted: isReset ? (_) => _submit() : null,
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^\s@]+@[^\s@]+$').hasMatch(email)
                    ? null
                    : 'أدخل بريداً إلكترونياً صالحاً';
              },
            ),
            if (!isReset) ...[
              SizedBox(height: 12.h),
              TextFormField(
                controller: _password,
                enabled: !busy,
                textDirection: TextDirection.ltr,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: [
                  isLogin ? AutofillHints.password : AutofillHints.newPassword,
                ],
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'أدخل كلمة المرور';
                  if (!isLogin && value.length < 6) {
                    return 'استخدم ستة أحرف على الأقل';
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: 20.h),
            AppButton(
              text: isReset ? 'إرسال رابط الاستعادة' : title,
              onPressed: busy ? null : _submit,
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => context.go(
                      isLogin
                          ? AppConstants.registerPath
                          : AppConstants.loginPath,
                    ),
              child: Text(isLogin ? 'إنشاء حساب' : 'العودة إلى تسجيل الدخول'),
            ),
            if (isLogin)
              TextButton(
                onPressed: busy
                    ? null
                    : () => context.go(AppConstants.resetPath),
                child: const Text('نسيت كلمة المرور؟'),
              ),
          ],
        ),
      ),
    );
  }
}
