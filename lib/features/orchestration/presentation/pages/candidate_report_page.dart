import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:hire/features/orchestration/presentation/cubit/candidate_report_cubit.dart';
import 'package:hire/core/services/file_saver/file_saver.dart' as fs;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CandidateReportPage extends StatefulWidget {
  final String sessionId;
  final String candidateId;
  final String candidateName;
  final CandidateStatus currentStatus;

  const CandidateReportPage({
    super.key,
    required this.sessionId,
    required this.candidateId,
    required this.candidateName,
    required this.currentStatus,
  });

  @override
  State<CandidateReportPage> createState() => _CandidateReportPageState();
}

class _CandidateReportPageState extends State<CandidateReportPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReport();
  }

  void _loadReport() {
    context.read<CandidateReportCubit>().loadCandidateReport(
          sessionId: widget.sessionId,
          candidateId: widget.candidateId,
          currentStatus: widget.currentStatus,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // PDF Export helper
  Future<void> _exportPdf(
    String candidateName,
    String jobTitle,
    double overallScore,
    String recommendation,
    String coordinatorNotes,
    double screeningScore,
    double technicalScore,
    double culturalScore,
    List<String> strengths,
    List<String> weaknesses,
    List<String> questions,
    String screeningSummary,
    String reviewSummary,
    String interviewSummary,
    String culturalSummary,
  ) async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      // Header Banner
      page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(99, 102, 241)), // Indigo
        bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 60),
      );

      page.graphics.drawString(
        'HIRE - AI RECRUITMENT REPORT',
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
        brush: PdfBrushes.white,
        bounds: const Rect.fromLTWH(20, 18, 400, 30),
      );

      // Metedata Section
      final double startY = 80;
      page.graphics.drawString(
        'Candidate Name: $candidateName\nJob Position: $jobTitle\nOverall Match: ${(overallScore * 10).toStringAsFixed(0)}%\nRecommendation: ${recommendation.toUpperCase()}',
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(20, startY, 500, 70),
      );

      // Score Grid
      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(229, 231, 235), width: 1),
        bounds: Rect.fromLTWH(20, startY + 80, page.getClientSize().width - 40, 50),
      );
      page.graphics.drawString(
        'Screening: ${(screeningScore * 10).toStringAsFixed(0)}%    |    Technical: ${(technicalScore * 10).toStringAsFixed(0)}%    |    Cultural: ${(culturalScore * 10).toStringAsFixed(0)}%',
        PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(30, startY + 98, 450, 20),
      );

      // Section 1: Coordinator Assessment
      double nextY = startY + 150;
      page.graphics.drawString(
        '1. Executive Summary',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(20, nextY, 400, 20),
      );
      page.graphics.drawString(
        coordinatorNotes.isNotEmpty ? coordinatorNotes : 'No summary notes available.',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(20, nextY + 25, page.getClientSize().width - 40, 60),
      );

      // Section 2: Screening Strengths and Weaknesses
      nextY += 100;
      page.graphics.drawString(
        '2. Screening Details',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(20, nextY, 400, 20),
      );
      
      page.graphics.drawString(
        'Strengths:\n${strengths.isNotEmpty ? strengths.map((s) => " - $s").join("\n") : " - No specific strengths highlighted."}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(20, nextY + 25, 230, 120),
      );

      page.graphics.drawString(
        'Development Areas:\n${weaknesses.isNotEmpty ? weaknesses.map((w) => " - $w").join("\n") : " - No major development areas highlighted."}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(260, nextY + 25, 230, 120),
      );

      // Section 3: Interview Q&As
      nextY += 150;
      page.graphics.drawString(
        '3. Simulated Interview Questions',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(20, nextY, 400, 20),
      );

      String qText = questions.isNotEmpty
          ? questions.map((q) => "Q: $q\n(Simulation response evaluated inside system)\n").join("\n")
          : "No simulation questions generated.";
      
      page.graphics.drawString(
        qText,
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(20, nextY + 25, page.getClientSize().width - 40, 150),
      );

      final List<int> bytes = await document.save();
      document.dispose();

      final safeName = candidateName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      await fs.saveAndLaunchFile(bytes, 'Report_$safeName.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم تحميل تقرير PDF بنجاح'
                  : 'PDF Report downloaded successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تقرير تقييم المرشح' : 'Candidate Assessment Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/recruitment/${widget.sessionId}/reports'),
        ),
      ),
      body: BlocConsumer<CandidateReportCubit, CandidateReportState>(
        listener: (context, state) {
          if (state is CandidateReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CandidateReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CandidateReportLoaded) {
            final report = state.report;
            final results = state.agentResults.cast<AgentResultEntity>();
            final currentDecision = state.candidateStatus;

            // Extract agent details safely
            final screeningAgentResult = results.firstWhere(
              (r) => r.agentType == AgentType.screening,
              orElse: () => _stubAgentResult(AgentType.screening),
            );
            final reviewerAgentResult = results.firstWhere(
              (r) => r.agentType == AgentType.adversarialReview,
              orElse: () => _stubAgentResult(AgentType.adversarialReview),
            );
            final interviewAgentResult = results.firstWhere(
              (r) => r.agentType == AgentType.technicalInterview,
              orElse: () => _stubAgentResult(AgentType.technicalInterview),
            );
            final culturalAgentResult = results.firstWhere(
              (r) => r.agentType == AgentType.culturalAssessment,
              orElse: () => _stubAgentResult(AgentType.culturalAssessment),
            );

            // Extract strengths/weaknesses from screening raw_data
            final screeningRaw = screeningAgentResult.rawData;
            final strengths = List<String>.from(screeningRaw['strengths'] ?? []);
            final weaknesses = List<String>.from(screeningRaw['weaknesses'] ?? []);

            // Extract interview questions from raw_data
            final interviewRaw = interviewAgentResult.rawData;
            final questions = List<String>.from(interviewRaw['questions'] ?? []);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Candidate header details card
                            _buildCandidateHeaderCard(
                              widget.candidateName,
                              report.overallScore,
                              report.finalRecommendation,
                              theme,
                              isAr,
                              () => _exportPdf(
                                widget.candidateName,
                                isAr ? 'تفاصيل الوظيفة المعنية' : 'Target Position',
                                report.overallScore,
                                report.finalRecommendation.name,
                                report.summaryNotes,
                                report.screeningScore,
                                report.technicalScore,
                                report.culturalScore,
                                strengths,
                                weaknesses,
                                questions,
                                screeningAgentResult.summary,
                                reviewerAgentResult.summary,
                                interviewAgentResult.summary,
                                culturalAgentResult.summary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Coordinator summary & conflict alerts
                            _buildCoordinatorSummary(report, theme, isAr),
                            const SizedBox(height: 24),

                            // Tab bar for Agents
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF16122C) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                children: [
                                  TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    labelColor: theme.colorScheme.primary,
                                    unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                                    indicatorColor: theme.colorScheme.primary,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    tabs: [
                                      Tab(text: isAr ? 'الفرز' : 'Screening'),
                                      Tab(text: isAr ? 'المراجع' : 'Reviewer'),
                                      Tab(text: isAr ? 'المقابلة' : 'Interview'),
                                      Tab(text: isAr ? 'التقييم الثقافي' : 'Cultural Fit'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 380,
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildScreeningTab(screeningAgentResult, strengths, weaknesses, theme, isAr),
                                        _buildReviewerTab(reviewerAgentResult, theme, isAr),
                                        _buildInterviewTab(interviewAgentResult, questions, theme, isAr),
                                        _buildCulturalTab(culturalAgentResult, theme, isAr),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom control panel for manual action
                _buildActionControlPanel(
                  widget.candidateId,
                  currentDecision,
                  theme,
                  isAr,
                ),
              ],
            );
          }

          if (state is CandidateReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(isAr ? 'فشل تحميل التقرير' : 'Failed to load report'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReport,
                    child: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCandidateHeaderCard(
    String name,
    double overallScore,
    AgentRecommendation recommendation,
    ThemeData theme,
    bool isAr,
    VoidCallback onDownloadPdf,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final recommendationColors = {
      AgentRecommendation.accept: Colors.green,
      AgentRecommendation.reject: Colors.red,
      AgentRecommendation.maybe: Colors.orange,
    };
    final color = recommendationColors[recommendation] ?? Colors.grey;

    final labels = {
      AgentRecommendation.accept: isAr ? 'موصى بالقبول' : 'Recommend Accept',
      AgentRecommendation.reject: isAr ? 'موصى بالرفض' : 'Recommend Reject',
      AgentRecommendation.maybe: isAr ? 'مراجعة معلقة' : 'Requires Review',
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16122C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          // Visual Match Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: overallScore / 10.0,
                  strokeWidth: 8,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(overallScore * 10).toStringAsFixed(0)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    isAr ? 'المطابقة' : 'Match',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    labels[recommendation] ?? '',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PDF Export Trigger button
          OutlinedButton.icon(
            onPressed: onDownloadPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(isAr ? 'تصدير PDF' : 'Export PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorSummary(
    dynamic report,
    ThemeData theme,
    bool isAr,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (report.hasConflict) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'تعارض تم اكتشافه بواسطة الوكلاء' : 'Conflict Detected by Reviewers',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.conflictNote ?? (isAr ? 'تم رصد تباين في تقييمات الفرز والمراجعة المعاكسة' : 'Differences detected between screening and adversarial reviews'),
                        style: const TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16122C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'التوصية النهائية والملخص التنسيقي' : 'Final Recommendation & Coordinator Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                report.summaryNotes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreeningTab(
    AgentResultEntity result,
    List<String> strengths,
    List<String> weaknesses,
    ThemeData theme,
    bool isAr,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgentScoreRow(isAr ? 'أخصائي الفرز' : 'Screening Agent', result.score, theme, isAr),
          const SizedBox(height: 12),
          Text(result.summary, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'نقاط القوة' : 'Strengths',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    ...strengths.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    if (strengths.isEmpty)
                      Text(isAr ? 'لم يذكر نقاط محددة' : 'No specific strengths listed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'نقاط التطوير' : 'Development Areas',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ...weaknesses.map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.remove_circle_outline, color: Colors.red, size: 14),
                              const SizedBox(width: 8),
                              Expanded(child: Text(w, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    if (weaknesses.isEmpty)
                      Text(isAr ? 'لم تذكر تحديات بارزة' : 'No major challenges listed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReviewerTab(AgentResultEntity result, ThemeData theme, bool isAr) {
    final biasDetected = result.rawData['bias_detected'] as bool? ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgentScoreRow(isAr ? 'المراجع المستقل' : 'Adversarial Reviewer', result.score, theme, isAr),
          const SizedBox(height: 12),
          Text(result.summary, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: biasDetected ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: biasDetected ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  biasDetected ? Icons.warning : Icons.check_circle,
                  color: biasDetected ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    biasDetected
                        ? (isAr ? '⚠️ تم رصد مؤشر انحياز في التقييم الأولي' : '⚠️ Potential bias detected in initial screening')
                        : (isAr ? '✅ لا توجد مؤشرات انحياز واضحة' : '✅ No significant biases detected'),
                    style: TextStyle(
                      color: biasDetected ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewTab(
    AgentResultEntity result,
    List<String> questions,
    ThemeData theme,
    bool isAr,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgentScoreRow(isAr ? 'أخصائي المقابلات' : 'Interview Simulator', result.score, theme, isAr),
          const SizedBox(height: 12),
          Text(result.summary, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Text(
            isAr ? 'الأسئلة التقنية المقترحة للمقابلة' : 'Suggested Interview Questions',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...questions.map((q) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q,
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
          if (questions.isEmpty)
            Text(isAr ? 'لا توجد أسئلة متوفرة' : 'No questions generated', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCulturalTab(AgentResultEntity result, ThemeData theme, bool isAr) {
    final valuesAlign = (result.rawData['values_alignment'] as num?)?.toDouble() ?? 5.0;
    final adaptability = (result.rawData['adaptability'] as num?)?.toDouble() ?? 5.0;
    final teamwork = (result.rawData['teamwork_indicators'] as num?)?.toDouble() ?? 5.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgentScoreRow(isAr ? 'أخصائي المواءمة الثقافية' : 'Cultural Fit Agent', result.score, theme, isAr),
          const SizedBox(height: 12),
          Text(result.summary, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          _buildMetricBar(isAr ? 'المواءمة مع القيم' : 'Values Alignment', valuesAlign, Colors.purple),
          const SizedBox(height: 10),
          _buildMetricBar(isAr ? 'القدرة على التكيف' : 'Adaptability', adaptability, Colors.teal),
          const SizedBox(height: 10),
          _buildMetricBar(isAr ? 'العمل الجماعي' : 'Teamwork', teamwork, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('${(score * 10).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 10,
            color: color,
            backgroundColor: Colors.white10,
            minHeight: 6,
          ),
        )
      ],
    );
  }

  Widget _buildAgentScoreRow(String agentName, double score, ThemeData theme, bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          agentName,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isAr ? 'التقييم: ${score.toStringAsFixed(1)}' : 'Score: ${score.toStringAsFixed(1)}',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionControlPanel(
    String candidateId,
    CandidateStatus status,
    ThemeData theme,
    bool isAr,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    if (status == CandidateStatus.accepted || status == CandidateStatus.rejected) {
      final isAccepted = status == CandidateStatus.accepted;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16122C) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAccepted ? Icons.check_circle : Icons.cancel,
                color: isAccepted ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isAccepted
                    ? (isAr ? 'تم قبول هذا المرشح بنجاح' : 'This candidate has been accepted')
                    : (isAr ? 'تم رفض هذا المرشح' : 'This candidate has been rejected'),
                style: TextStyle(
                  color: isAccepted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () => context.read<CandidateReportCubit>().updateCandidateDecision(candidateId, CandidateStatus.pending),
                child: Text(isAr ? 'تراجع عن القرار' : 'Reset Decision'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16122C) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF2E2A4F) : const Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<CandidateReportCubit>().updateCandidateDecision(candidateId, CandidateStatus.rejected),
                icon: const Icon(Icons.cancel_outlined),
                label: Text(isAr ? 'رفض المرشح' : 'Reject Candidate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.15),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<CandidateReportCubit>().updateCandidateDecision(candidateId, CandidateStatus.accepted),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(isAr ? 'قبول المرشح' : 'Accept Candidate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper stub for fallback
  AgentResultEntity _stubAgentResult(AgentType type) {
    return AgentResultEntity(
      id: '',
      sessionId: '',
      candidateId: '',
      agentType: type,
      score: 5.0,
      summary: 'No details recorded.',
      recommendation: AgentRecommendation.maybe,
      rawData: const {},
      createdAt: DateTime.now(),
    );
  }
}
