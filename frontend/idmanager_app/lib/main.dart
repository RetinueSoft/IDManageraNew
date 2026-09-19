import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/security/session_controller.dart';
import 'foundation/theme/app_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: IdManagerApp()));
}

class IdManagerApp extends ConsumerWidget {
  const IdManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    if (session.isLoading) {
      return MaterialApp(
        title: 'IDManager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (session.value == null) {
      return MaterialApp(
        title: 'IDManager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const LoginScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'IDManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
