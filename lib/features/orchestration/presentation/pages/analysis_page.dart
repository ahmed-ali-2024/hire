import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hire/core/logger/app_logger.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';
import 'package:hire/features/orchestration/presentation/cubit/orchestration_cubit.dart';
import 'package:hire/features/orchestration/presentation/cubit/orchestration_state.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalysisPage extends StatefulWidget {
  final String sessionId;
  final String jobTitle;
  final String jobDescription;
  final List<CandidateEntity> candidates;

  const AnalysisPage({
    super.key,
    required this.sessionId,
    required this.jobTitle,
    required this.jobDescription,
    required this.candidates,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  final List<Map<String, dynamic>> _bandMessages = [];
  RealtimeChannel? _realtimeChannel;
  bool _started = false;

  final List<_AgentStep> _steps = [
    _AgentStep('screening', 'Screening Agent', '🔍', 'Analyzing CV against job requirements'),
    _AgentStep('adversarialReview', 'Adversarial Reviewer', '⚔️', 'Critical review for bias detection'),
    _AgentStep('technicalInterview', 'Interview Agent', '💼', 'Technical assessment simulation'),
    _AgentStep('culturalAssessment', 'Cultural Fit Agent', '🌐', 'Cultural alignment evaluation'),
    _AgentStep('coordination', 'Coordinator Agent', '🎯', 'Final report synthesis'),
  ];

  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _subscribeToRealtimeMessages();
    _startAnalysis();
  }

  void _subscribeToRealtimeMessages() {
    _realtimeChannel = Supabase.instance.client
        .channel('band_messages_${widget.sessionId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'band_messages_log',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: widget.sessionId,
          ),
          callback: (payload) {
            if (mounted) {
              setState(() {
                _bandMessages.add(payload.newRecord);
                // Advance step indicator
                final agent = payload.newRecord['sender_agent'] as String? ?? '';
                final stepIdx = _steps.indexWhere((s) => s.key == agent);
                if (stepIdx != -1 && stepIdx > _activeStep) {
                  _activeStep = stepIdx + 1;
                }
              });
            }
          },
        )
        .subscribe();
  }

  void _startAnalysis() {
    if (_started) return;
    _started = true;

    // Simulate step advancement while waiting for real results
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _activeStep = 1);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrchestrationCubit>().startOrchestration(
            sessionId: widget.sessionId,
            jobTitle: widget.jobTitle,
            jobDescription: widget.jobDescription,
            candidates: widget.candidates,
          );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: BlocConsumer<OrchestrationCubit, OrchestrationState>(
        listener: (context, state) {
          if (state is OrchestrationCompleted) {
            setState(() => _activeStep = _steps.length);
            _progressController.forward();
          } else if (state is OrchestrationError) {
            AppLogger.instance.e('Orchestration error on UI', state.message);
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    _buildStatusCard(state),
                    const SizedBox(height: 24),
                    _buildAgentPipeline(state),
                    const SizedBox(height: 24),
                    if (_bandMessages.isNotEmpty) ...[
                      _buildBandMessagesPanel(),
                      const SizedBox(height: 24),
                    ],
                    if (state is OrchestrationCompleted) ...[
                      _buildResultsPanel(state.reports),
                      const SizedBox(height: 24),
                      _buildCompletedActions(state),
                    ],
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E1A),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1F35), Color(0xFF0A0E1A)],
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Agent Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.jobTitle,
              style: const TextStyle(
                color: Color(0xFF6C7AFF),
                fontSize: 12,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white70),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildStatusCard(OrchestrationState state) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (state is OrchestrationCompleted) {
      statusText = 'Analysis Complete';
      statusColor = const Color(0xFF00E5A0);
      statusIcon = Icons.check_circle_outline;
    } else if (state is OrchestrationError) {
      statusText = 'Analysis Failed';
      statusColor = const Color(0xFFFF4C6E);
      statusIcon = Icons.error_outline;
    } else {
      statusText = 'Agents Working...';
      statusColor = const Color(0xFF6C7AFF);
      statusIcon = Icons.auto_awesome;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(
                  state is OrchestrationAnalyzing
                      ? 0.1 + (_pulseController.value * 0.2)
                      : 0.2,
                ),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.candidates.length} candidate${widget.candidates.length > 1 ? 's' : ''} · Band.ai Connected',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentPipeline(OrchestrationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C7AFF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Agent Pipeline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_steps.length, (i) => _buildStepTile(i, state)),
        ],
      ),
    );
  }

  Widget _buildStepTile(int index, OrchestrationState state) {
    final step = _steps[index];
    final isCompleted = state is OrchestrationCompleted || index < _activeStep;
    final isActive = state is! OrchestrationCompleted && index == _activeStep;
    final isPending = !isCompleted && !isActive;

    Color dotColor;
    if (isCompleted) {
      dotColor = const Color(0xFF00E5A0);
    } else if (isActive) {
      dotColor = const Color(0xFF6C7AFF);
    } else {
      dotColor = Colors.white24;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Column(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor.withOpacity(isActive ? 0.15 + (_pulseController.value * 0.1) : 0.1),
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Color(0xFF00E5A0), size: 16)
                        : Text(
                            step.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                ),
              ),
              if (index < _steps.length - 1)
                Container(
                  width: 2,
                  height: 32,
                  color: isCompleted ? const Color(0xFF00E5A0).withOpacity(0.4) : Colors.white12,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: isPending ? Colors.white38 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: isPending ? Colors.white24 : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 3,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => LinearProgressIndicator(
                          value: null,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF6C7AFF).withOpacity(0.7 + _pulseController.value * 0.3),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandMessagesPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C7AFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C7AFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6C7AFF).withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broadcast_on_home, color: Color(0xFF6C7AFF), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Band.ai Live',
                      style: TextStyle(color: Color(0xFF6C7AFF), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_bandMessages.length} messages',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._bandMessages.take(5).map((msg) => _buildMessageBubble(msg)),
          if (_bandMessages.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${_bandMessages.length - 5} more messages in Band Dashboard',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final sender = msg['sender_agent'] as String? ?? 'agent';
    final receiver = msg['receiver_agent'] as String? ?? '';
    final payload = msg['payload'] as Map<String, dynamic>? ?? {};
    final summary = payload['summary'] as String? ?? payload.toString();
    final score = payload['score'];

    final agentColors = {
      'screening': const Color(0xFF6C7AFF),
      'adversarialReview': const Color(0xFFFF6B6B),
      'technicalInterview': const Color(0xFFFFB347),
      'culturalAssessment': const Color(0xFF00E5A0),
      'coordination': const Color(0xFFFF79C6),
    };
    final color = agentColors[sender] ?? Colors.white38;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                _agentDisplayName(sender),
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (receiver.isNotEmpty) ...[
                const Text(' → ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                Text(
                  _agentDisplayName(receiver),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
              if (score != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(score as num).toStringAsFixed(1)}/10',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              summary.length > 120 ? '${summary.substring(0, 120)}...' : summary,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsPanel(List<FinalReportEntity> reports) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5A0).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Color(0xFF00E5A0), size: 20),
              SizedBox(width: 8),
              Text(
                'Final Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reports.map((report) => _buildReportCard(report)),
        ],
      ),
    );
  }

  Widget _buildReportCard(FinalReportEntity report) {
    final recommendation = report.finalRecommendation;
    final colors = {
      AgentRecommendation.accept: const Color(0xFF00E5A0),
      AgentRecommendation.reject: const Color(0xFFFF4C6E),
      AgentRecommendation.maybe: const Color(0xFFFFB347),
    };
    final color = colors[recommendation] ?? Colors.white38;
    final labels = {
      AgentRecommendation.accept: '✅ ACCEPT',
      AgentRecommendation.reject: '❌ REJECT',
      AgentRecommendation.maybe: '🤔 REVIEW',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Score',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                    ),
                    Text(
                      '${report.overallScore.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        color: color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  labels[recommendation] ?? '',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScoreRow('Screening', report.screeningScore, const Color(0xFF6C7AFF)),
          _buildScoreRow('Technical', report.technicalScore, const Color(0xFFFFB347)),
          _buildScoreRow('Cultural', report.culturalScore, const Color(0xFF00E5A0)),
          if (report.hasConflict) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB347).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFFFB347), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.conflictNote ?? 'Conflict detected between agents',
                      style: const TextStyle(color: Color(0xFFFFB347), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            report.summaryNotes,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedActions(OrchestrationCompleted state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Session'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C7AFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (state.bandRoomId.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6C7AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF6C7AFF).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.broadcast_on_home, color: Color(0xFF6C7AFF), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'View in Band Dashboard',
                        style: TextStyle(color: Color(0xFF6C7AFF), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Room: ${state.bandRoomId.substring(0, 8)}...',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, color: Color(0xFF6C7AFF), size: 16),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _agentDisplayName(String key) {
    const names = {
      'screening': 'Screening Agent',
      'adversarialReview': 'Adversarial Reviewer',
      'technicalInterview': 'Interview Agent',
      'culturalAssessment': 'Cultural Agent',
      'coordination': 'Coordinator',
    };
    return names[key] ?? key;
  }
}

class _AgentStep {
  final String key;
  final String title;
  final String emoji;
  final String description;

  const _AgentStep(this.key, this.title, this.emoji, this.description);
}
