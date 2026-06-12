import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hire/features/recruitment/domain/entities/recruitment_session_entity.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import '../cubit/session_detail_cubit.dart';
import '../cubit/session_detail_state.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    context.read<SessionDetailCubit>().loadSessionDetail(widget.sessionId);
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

  Color _getCandidateStatusColor(CandidateStatus status) {
    switch (status) {
      case CandidateStatus.accepted:
        return Colors.green;
      case CandidateStatus.rejected:
        return Colors.red;
      case CandidateStatus.analyzed:
        return Colors.teal;
      case CandidateStatus.analyzing:
        return Colors.blue;
      case CandidateStatus.reviewRequested:
        return Colors.purple;
      case CandidateStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تفاصيل الجلسة' : 'Session Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/dashboard'),
        ),
      ),
      body: BlocBuilder<SessionDetailCubit, SessionDetailState>(
        builder: (context, state) {
          if (state is SessionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SessionDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SessionDetailLoaded) {
            final session = state.session;
            final candidates = state.candidates;
            final statusColor = _getStatusColor(session.status, theme);
            final formattedDate = DateFormat.yMMMd(isAr ? 'ar' : 'en').add_jm().format(session.createdAt);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card with status and actions
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        shadowColor: theme.shadowColor.withValues(alpha: 0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.jobTitle,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      session.status.name.toUpperCase(),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Created on $formattedDate',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Expandable Job Description
                              Theme(
                                data: theme.copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  title: Text(
                                    'Job Description & Details',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      width: double.infinity,
                                      child: SelectableText(
                                        session.jobDescription.isNotEmpty 
                                            ? session.jobDescription 
                                            : 'No job description provided.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Start analysis button if pending or failed
                              if (session.status == SessionStatus.pending || session.status == SessionStatus.failed)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/app/analysis/${session.id}',
                                        extra: {
                                          'jobTitle': session.jobTitle,
                                          'jobDescription': session.jobDescription,
                                          'candidates': candidates,
                                        },
                                      ).then((_) {
                                        _fetchDetails();
                                      });
                                    },
                                    icon: const Icon(Icons.rocket_launch),
                                    label: Text(isAr ? 'بدء تحليل وكلاء الذكاء الاصطناعي' : 'Start AI Agents Analysis'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                              else if (session.status == SessionStatus.analyzing)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/app/analysis/${session.id}',
                                        extra: {
                                          'jobTitle': session.jobTitle,
                                          'jobDescription': session.jobDescription,
                                          'candidates': candidates,
                                        },
                                      ).then((_) {
                                        _fetchDetails();
                                      });
                                    },
                                    icon: const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    label: Text(isAr ? 'عرض تقدم التحليل الحالي' : 'View Current Analysis Progress'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                              else if (session.status == SessionStatus.completed)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/app/analysis/${session.id}',
                                        extra: {
                                          'jobTitle': session.jobTitle,
                                          'jobDescription': session.jobDescription,
                                          'candidates': candidates,
                                        },
                                      ).then((_) {
                                        _fetchDetails();
                                      });
                                    },
                                    icon: const Icon(Icons.analytics_outlined),
                                    label: Text(isAr ? 'عرض تقارير وتحليلات الوكلاء' : 'View Agent Reports & Analysis'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Candidates List Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Candidates (${candidates.length})',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _fetchDetails,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (candidates.isEmpty)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No candidates uploaded yet',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = candidates[index];
                            final candColor = _getCandidateStatusColor(candidate.status);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.dividerColor.withValues(alpha: 0.05),
                                ),
                              ),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                      child: Text(
                                        candidate.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            candidate.name,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.description_outlined, size: 14, color: theme.colorScheme.secondary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  candidate.fileName,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.secondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Candidate Status Label
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: candColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: candColor.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        candidate.status.name.toUpperCase(),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: candColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Match Score if analyzed
                                    if (candidate.overallScore != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'MATCH',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            '${(candidate.overallScore! * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
