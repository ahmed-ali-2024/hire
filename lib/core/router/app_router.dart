import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/recruitment/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_shell_layout.dart';
import 'error_page.dart';

// ChangeNotifier that listens to AuthCubit to trigger GoRouter refreshes on authentication changes.
class AuthStateListenable extends ChangeNotifier {
  final AuthCubit authCubit;
  late final StreamSubscription _subscription;

  AuthStateListenable(this.authCubit) {
    _subscription = authCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/app/dashboard',
    refreshListenable: AuthStateListenable(sl<AuthCubit>()),
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthLoading || authState is AuthInitial) {
        return null;
      }

      if (authState is AuthUnauthenticated) {
        // User not logged in, redirect to login if attempting protected route
        return loggingIn ? null : '/login';
      }

      if (authState is AuthAuthenticated) {
        // User logged in, redirect to dashboard if attempting login/register
        return loggingIn ? '/app/dashboard' : null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellLayout(child: child),
        routes: [
          GoRoute(
            path: '/app/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/app/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
