import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hire - AI Recruitment',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: Text('Authenticated: Dashboard Coming Soon')),
            );
          } else if (state is AuthUnauthenticated) {
            return const Scaffold(
              body: Center(child: Text('Login Page Coming Soon')),
            );
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Initializing...')),
            );
          }
        },
      ),
    );
  }
}
