import 'package:flutter/material.dart';

class AppShellLayout extends StatelessWidget {
  final Widget child;

  const AppShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Shared layout wrapper for the authenticated area of the application
    return Scaffold(
      body: child,
    );
  }
}
