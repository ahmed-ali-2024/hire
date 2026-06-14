import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hire/core/l10n/app_localizations.dart';
import 'package:hire/features/recruitment/domain/entities/recruitment_session_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../cubit/recruitment_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  void _fetchSessions() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<RecruitmentCubit>().loadSessions(authState.user.id);
    }
  }

  Color _getStatusColor(SessionStatus status, ThemeData theme) {
    switch (status) {
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.analyzing:
        return theme.colorScheme.primary;
      case SessionStatus.failed:
        return Colors.red;
      case SessionStatus.pending:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return Icons.check_circle_outline;
      case SessionStatus.analyzing:
        return Icons.insights;
      case SessionStatus.failed:
        return Icons.error_outline;
      case SessionStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            tooltip: l10n.language,
          ),
          // IconButton(
          //   icon: Icon(
          //     context.watch<ThemeCubit>().state == ThemeMode.dark
          //         ? Icons.light_mode_outlined
          //         : Icons.dark_mode_outlined,
          //   ),
          //   onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          //   tooltip: l10n.theme,
          // ),
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
      body: BlocBuilder<RecruitmentCubit, RecruitmentState>(
        builder: (context, state) {
          if (state is RecruitmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecruitmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchSessions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is RecruitmentLoaded) {
            final sessions = state.sessions;

            if (sessions.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 100,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No recruitment sessions yet',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first session and upload CVs to start analysis',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/app/recruitment/new'),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newRecruitment),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.go('/app/recruitment/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.newRecruitment),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              body: ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final statusColor = _getStatusColor(session.status, theme);
                  final formattedDate = DateFormat.yMMMd(isAr ? 'ar' : 'en').add_jm().format(session.createdAt);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    elevation: 2,
                    shadowColor: theme.shadowColor.withValues(alpha: 0.04),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.go('/app/recruitment/${session.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.jobTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.people_outline, size: 16, color: theme.colorScheme.secondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${session.candidatesCount} candidates',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.secondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        formattedDate,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(session.status),
                                    color: statusColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    session.status.name.toUpperCase(),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
