import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/auth_bloc.dart';

class AuthPanel extends StatelessWidget {
  const AuthPanel({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final busy = context.select((AuthBloc bloc) => bloc.state.busy);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    primary.withValues(alpha: 0.1),
                    theme.colorScheme.surface,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: BorderDirectional(
                    start: BorderSide(color: primary, width: 6.w),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ...children,
                      if (busy) const DelayedProgress(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DelayedProgress extends StatelessWidget {
  const DelayedProgress({super.key, this.skeleton = false});

  final bool skeleton;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 450),
    builder: (context, value, child) =>
        value < 2 / 3 ? const SizedBox.shrink() : child!,
    child: skeleton
        ? Semantics(
            label: 'جارٍ استعادة الجلسة',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final width in [1.0, 0.65])
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: width,
                      child: SizedBox(
                        height: 16.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: const LinearProgressIndicator(
              semanticsLabel: 'جارٍ التنفيذ',
            ),
          ),
  );
}
