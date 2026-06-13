import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hire/core/l10n/app_localizations.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';
import 'package:hire/features/orchestration/presentation/cubit/orchestration_cubit.dart';
import 'package:hire/features/orchestration/presentation/cubit/orchestration_state.dart';
import 'package:hire/features/recruitment/presentation/cubit/session_detail_cubit.dart';
import 'package:hire/features/recruitment/presentation/cubit/session_detail_state.dart';

class ReportsPage extends StatefulWidget {
  final String sessionId;

  const ReportsPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _searchQuery = '';
  AgentRecommendation? _filterRecommendation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<OrchestrationCubit>().loadSessionReports(widget.sessionId);
    context.read<SessionDetailCubit>().loadSessionDetail(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'نتائج وتقارير التوظيف' : 'Recruitment Reports & Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/recruitment/${widget.sessionId}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrchestrationCubit, OrchestrationState>(
            listener: (context, state) {
              if (state is OrchestrationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SessionDetailCubit, SessionDetailState>(
          builder: (context, sessionState) {
            if (sessionState is SessionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (sessionState is SessionDetailError) {
              return Center(child: Text(sessionState.message));
            }
            if (sessionState is SessionDetailLoaded) {
              final session = sessionState.session;
              final candidatesMap = {for (var c in sessionState.candidates) c.id: c};

              return BlocBuilder<OrchestrationCubit, OrchestrationState>(
                builder: (context, state) {
                  if (state is OrchestrationAnalyzing) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading reports and calculations...'),
                        ],
                      ),
                    );
                  }

                  if (state is OrchestrationCompleted) {
                    final reports = state.reports;
                    if (reports.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              isAr ? 'لا توجد تقارير متوفرة بعد' : 'No reports available yet',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter and search
                    final filteredReports = reports.where((report) {
                      final candidate = candidatesMap[report.candidateId];
                      final name = candidate?.name.toLowerCase() ?? '';
                      final matchesSearch = name.contains(_searchQuery.toLowerCase());
                      final matchesFilter = _filterRecommendation == null ||
                          report.finalRecommendation == _filterRecommendation;
                      return matchesSearch && matchesFilter;
                    }).toList();

                    // Calculate average overall score
                    final avgScore = reports.isEmpty
                        ? 0.0
                        : reports.map((r) => r.overallScore).reduce((a, b) => a + b) / reports.length;
                    final acceptedCount = reports.where((r) => r.finalRecommendation == AgentRecommendation.accept).length;
                    final rejectedCount = reports.where((r) => r.finalRecommendation == AgentRecommendation.reject).length;
                    final reviewCount = reports.where((r) => r.finalRecommendation == AgentRecommendation.maybe).length;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Session header card
                              _buildSessionInfoCard(session.jobTitle, reports.length, theme, isAr),
                              const SizedBox(height: 24),

                              // Quick Statistics Panel
                              _buildStatsPanel(avgScore, acceptedCount, rejectedCount, reviewCount, theme, isAr),
                              const SizedBox(height: 32),

                              // Search and Filter Bar
                              _buildSearchFilterBar(theme, isAr),
                              const SizedBox(height: 20),

                              // Candidates Grid / List
                              filteredReports.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                                      child: Center(
                                        child: Text(
                                          isAr ? 'لا توجد نتائج مطابقة للبحث' : 'No matching results found',
                                          style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredReports.length,
                                      itemBuilder: (context, index) {
                                        final report = filteredReports[index];
                                        final candidate = candidatesMap[report.candidateId];
                                        if (candidate == null) return const SizedBox.shrink();

                                        return _buildCandidateReportCard(
                                          report,
                                          candidate.name,
                                          candidate.status,
                                          theme,
                                          isAr,
                                          l10n,
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(String jobTitle, int totalCandidates, ThemeData theme, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF1E1B4B), const Color(0xFF111827)]
              : [const Color(0xFFEEF2FF), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.work_outline, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تقرير التقييم النهائي لوظيفة' : 'Final Assessment Report for',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jobTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(
    double avgScore,
    int accepted,
    int rejected,
    int review,
    ThemeData theme,
    bool isAr,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          children: [
            _buildStatCard(
              isAr ? 'متوسط الملاءمة' : 'Average Match',
              '${(avgScore * 10).toStringAsFixed(0)}%',
              Icons.analytics,
              theme.colorScheme.primary,
              theme,
            ),
            _buildStatCard(
              isAr ? 'موصى بقبولهم' : 'Recommended',
              '$accepted',
              Icons.check_circle_outline,
              Colors.green,
              theme,
            ),
            _buildStatCard(
              isAr ? 'موصى برفضهم' : 'Rejected',
              '$rejected',
              Icons.cancel_outlined,
              Colors.red,
              theme,
            ),
            _buildStatCard(
              isAr ? 'يحتاج مراجعة' : 'Need Review',
              '$review',
              Icons.help_outline,
              Colors.orange,
              theme,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16122C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(ThemeData theme, bool isAr) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16122C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.hintColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: isAr ? 'البحث عن مرشح...' : 'Search candidate...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter Recommendation Dropdown
          DropdownButton<AgentRecommendation>(
            value: _filterRecommendation,
            underline: const SizedBox(),
            hint: Text(isAr ? 'الكل' : 'All Recommendations'),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(isAr ? 'كل التوصيات' : 'All'),
              ),
              DropdownMenuItem(
                value: AgentRecommendation.accept,
                child: Text(isAr ? 'مقبول' : 'Accept'),
              ),
              DropdownMenuItem(
                value: AgentRecommendation.reject,
                child: Text(isAr ? 'مرفوض' : 'Reject'),
              ),
              DropdownMenuItem(
                value: AgentRecommendation.maybe,
                child: Text(isAr ? 'مراجعة' : 'Review'),
              ),
            ],
            onChanged: (val) {
              setState(() {
                _filterRecommendation = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateReportCard(
    FinalReportEntity report,
    String candidateName,
    dynamic currentStatus, // candidate status
    ThemeData theme,
    bool isAr,
    AppLocalizations l10n,
  ) {
    final recommendation = report.finalRecommendation;
    final colors = {
      AgentRecommendation.accept: Colors.green,
      AgentRecommendation.reject: Colors.red,
      AgentRecommendation.maybe: Colors.orange,
    };
    final color = colors[recommendation] ?? Colors.grey;
    final isDark = theme.brightness == Brightness.dark;

    final labels = {
      AgentRecommendation.accept: isAr ? 'موصى بالقبول' : 'Recommend Accept',
      AgentRecommendation.reject: isAr ? 'موصى بالرفض' : 'Recommend Reject',
      AgentRecommendation.maybe: isAr ? 'يتطلب مراجعة' : 'Requires Review',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/app/recruitment/${widget.sessionId}/candidate/${report.candidateId}', extra: {
            'candidateName': candidateName,
            'currentStatus': currentStatus,
          }).then((_) {
            _loadData();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      candidateName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidateName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            labels[recommendation] ?? '',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Matches overall score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isAr ? 'الدرجة الكلية' : 'Match Score',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${(report.overallScore * 10).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // Sub-scores display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubScoreText(isAr ? 'الفرز' : 'Screening', report.screeningScore, const Color(0xFF6366F1), theme),
                  _buildSubScoreText(isAr ? 'التقني' : 'Technical', report.technicalScore, const Color(0xFF06B6D4), theme),
                  _buildSubScoreText(isAr ? 'الثقافي' : 'Cultural', report.culturalScore, const Color(0xFFD946EF), theme),
                ],
              ),
              if (report.hasConflict) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          report.conflictNote ?? (isAr ? 'تم اكتشاف تعارض في تقييمات الوكلاء' : 'Conflict detected in agent reviews'),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubScoreText(String label, double score, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${(score * 10).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
