import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/state/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: IdManagerApp()));
}

class IdManagerApp extends ConsumerWidget {
  const IdManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      title: 'IDManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: auth.isRestoring
          ? const _SplashScreen()
          : (auth.isAuthenticated ? const AppShell() : const LoginScreen()),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
