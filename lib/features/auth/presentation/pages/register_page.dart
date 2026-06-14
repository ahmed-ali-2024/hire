import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import 'widgets/auth_form_widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            tooltip: 'Toggle Language',
          ),
          // IconButton(
          //   icon: Icon(
          //     context.watch<ThemeCubit>().state == ThemeMode.dark
          //         ? Icons.light_mode_outlined
          //         : Icons.dark_mode_outlined,
          //   ),
          //   onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          //   tooltip: 'Toggle Theme',
          // ),
          const SizedBox(width: 12),
        ],
      ),
      body: const SafeArea(
        child: AuthFormWidget(isSignUp: true),
      ),
    );
  }
}
