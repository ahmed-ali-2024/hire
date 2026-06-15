import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

class AppShellLayout extends StatelessWidget {
  final Widget child;

  const AppShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Shared layout wrapper for the authenticated area of the application
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          body: child,
        );
      },
    );
  }
}
