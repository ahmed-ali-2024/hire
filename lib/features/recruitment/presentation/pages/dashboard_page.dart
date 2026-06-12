import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hire/core/l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userState = context.watch<AuthCubit>().state;
    final email = userState is AuthAuthenticated ? userState.user.email : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            tooltip: l10n.language,
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeCubit>().state == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            tooltip: l10n.theme,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/app/settings'),
            tooltip: l10n.settings,
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthCubit>().signOut(),
            tooltip: l10n.signOut,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Hire Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.go('/app/recruitment/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.newRecruitment),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
