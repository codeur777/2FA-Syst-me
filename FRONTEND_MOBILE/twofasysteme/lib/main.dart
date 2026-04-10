import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: const TwoFAApp(),
    ),
  );
}

class TwoFAApp extends StatelessWidget {
  const TwoFAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: '2FA Systeme',
      debugShowCheckedModeBanner: false,
      themeMode: auth.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: auth.loading
          ? const _SplashScreen()
          : auth.isLoggedIn
              ? const ProfileScreen()
              : const LoginScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
