import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/data/firebase_configuration.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/widgets/auth_feedback.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseOptions);
    final dependencies = configureDependencies(FirebaseAuth.instance);
    runApp(MyApp(createAuthBloc: dependencies.call<AuthBloc>));
  } on Exception catch (error) {
    AppLogger.log('Firebase initialization failed: ${error.runtimeType}');
    runApp(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('تعذّر تهيئة المصادقة. تحقق من إعدادات Firebase.'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.createAuthBloc});

  final AuthBloc Function() createAuthBloc;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _refresh = ValueNotifier<(bool, String?, bool?)>((false, null, null));
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  late final AuthBloc _auth;
  late final GoRouter _router;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void initState() {
    super.initState();
    _auth = widget.createAuthBloc();
    _router = createRouter(_auth, _refresh);
    _subscription = _auth.stream.listen((state) {
      _refresh.value = (
        state.sessionReady,
        state.user?.id,
        state.user?.emailVerified,
      );
    });
    _auth.add(const WatchSession());
  }

  @override
  void dispose() {
    _subscription.cancel();
    _router.dispose();
    _refresh.dispose();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _auth,
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp.router(
          title: AppConstants.name,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A),
              primary: const Color(0xFF1E3A8A),
              error: const Color(0xFFC62828),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: 'Cairo',
            fontFamilyFallback: const ['Tajawal'],
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          routerConfig: _router,
          scaffoldMessengerKey: _messenger,
          builder: (context, child) => BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final message = authFeedback(state);
              if (message == null) return;
              _messenger.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            child: child!,
          ),
        ),
      ),
    );
  }
}
