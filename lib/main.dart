import 'package:flutter/material.dart';
import 'package:flutter_cityweather_front/services/OnboardingStorage.dart';
import 'package:flutter_cityweather_front/services/auth/AuthRepository.dart';
import 'package:flutter_cityweather_front/services/auth/AuthSession.dart';
import 'package:flutter_cityweather_front/views/HomeView.dart';
import 'package:flutter_cityweather_front/views/LoginView.dart';
import 'package:flutter_cityweather_front/views/OnboardingView.dart';
import 'package:flutter_cityweather_front/views/RegisterView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CityWeather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final _authRepository = AuthRepository();
  final _onboardingStorage = OnboardingStorage();

  AuthSession? _session;
  bool _hasCompletedOnboarding = false;
  bool _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final hasCompleted = await _onboardingStorage.hasCompleted();
    AuthSession? restored;
    if (hasCompleted) {
      restored = await _authRepository.restoreSession();
    }
    if (!mounted) return;
    setState(() {
      _hasCompletedOnboarding = hasCompleted;
      _session = restored;
      _isBootstrapping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasCompletedOnboarding) {
      return OnboardingView(onFinished: _completeOnboarding);
    }

    if (_session == null) {
      return LoginView(
        authRepository: _authRepository,
        onLoginSuccess: _handleAuthenticated,
        onRegisterRequested: _openRegister,
      );
    }

    return HomeView(currentUser: _session?.user, onLogout: _logout);
  }

  Future<void> _completeOnboarding() async {
    await _onboardingStorage.markCompleted();
    if (!mounted) return;
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  void _handleAuthenticated(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    setState(() {
      _session = null;
    });
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RegisterView(
          authRepository: _authRepository,
          onRegisterSuccess: (session) {
            Navigator.of(ctx).pop();
            _handleAuthenticated(session);
          },
        ),
      ),
    );
  }
}
