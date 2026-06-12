import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hire/core/logger/app_logger.dart';
import 'package:hire/features/orchestration/data/repositories/orchestration_repository_impl.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';
import 'package:hire/features/orchestration/domain/repositories/orchestration_repository.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'orchestration_state.dart';

class OrchestrationCubit extends Cubit<OrchestrationState> {
  final OrchestrationRepositoryImpl repositoryImpl;
  final OrchestrationRepository repository;
  final SupabaseClient supabaseClient;

  OrchestrationCubit({
    required this.repositoryImpl,
    required this.repository,
    required this.supabaseClient,
  }) : super(const OrchestrationInitial());

  /// Starts the full orchestration for a session
  Future<void> startOrchestration({
    required String sessionId,
    required String jobTitle,
    required String jobDescription,
    required List<CandidateEntity> candidates,
  }) async {
    if (candidates.isEmpty) {
      emit(const OrchestrationError('No candidates to analyze'));
      return;
    }

    emit(OrchestrationAnalyzing(
      currentStep: 'Initializing agents...',
      completedSteps: 0,
      totalSteps: candidates.length * 5,
      candidateName: candidates.first.name,
    ));

    try {
      // Invoke Edge Function — it handles all agent logic + Band messaging
      final result = await repositoryImpl.runOrchestration(
        sessionId: sessionId,
        jobTitle: jobTitle,
        jobDescription: jobDescription,
        candidates: candidates,
      );

      result.fold(
        (failure) {
          AppLogger.instance.e('Orchestration failed', failure.message);
          emit(OrchestrationError(failure.message));
        },
        (data) async {
          final bandRoomId = data['bandRoomId'] as String? ?? '';
          final processedCount = data['processedCandidates'] as int? ?? candidates.length;

          // Load final reports
          final reportsResult = await repository.getFinalReports(sessionId);
          reportsResult.fold(
            (_) => emit(OrchestrationCompleted(
              reports: [],
              bandRoomId: bandRoomId,
              processedCandidates: processedCount,
            )),
            (reports) => emit(OrchestrationCompleted(
              reports: reports,
              bandRoomId: bandRoomId,
              processedCandidates: processedCount,
            )),
          );
        },
      );
    } catch (e) {
      AppLogger.instance.e('OrchestrationCubit error', e);
      emit(OrchestrationError(e.toString()));
    }
  }

  /// Load reports for an already-analyzed session
  Future<void> loadSessionReports(String sessionId) async {
    emit(const OrchestrationAnalyzing(
      currentStep: 'Loading results...',
      completedSteps: 0,
      totalSteps: 1,
      candidateName: '',
    ));

    final result = await repository.getFinalReports(sessionId);
    result.fold(
      (failure) => emit(OrchestrationError(failure.message)),
      (reports) => emit(OrchestrationCompleted(
        reports: reports,
        bandRoomId: '',
        processedCandidates: reports.length,
      )),
    );
  }

  List<FinalReportEntity> get currentReports {
    final s = state;
    if (s is OrchestrationCompleted) return s.reports;
    return [];
  }
}
