import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';
import 'package:hire/features/orchestration/domain/repositories/orchestration_repository.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:hire/features/recruitment/domain/repositories/recruitment_repository.dart';

abstract class CandidateReportState extends Equatable {
  const CandidateReportState();
  @override
  List<Object?> get props => [];
}

class CandidateReportInitial extends CandidateReportState {}

class CandidateReportLoading extends CandidateReportState {}

class CandidateReportLoaded extends CandidateReportState {
  final FinalReportEntity report;
  final List<AgentResultEntity> agentResults;
  final CandidateStatus candidateStatus;

  const CandidateReportLoaded({
    required this.report,
    required this.agentResults,
    required this.candidateStatus,
  });

  CandidateReportLoaded copyWith({
    FinalReportEntity? report,
    List<AgentResultEntity>? agentResults,
    CandidateStatus? candidateStatus,
  }) {
    return CandidateReportLoaded(
      report: report ?? this.report,
      agentResults: agentResults ?? this.agentResults,
      candidateStatus: candidateStatus ?? this.candidateStatus,
    );
  }

  @override
  List<Object?> get props => [report, agentResults, candidateStatus];
}

class CandidateReportError extends CandidateReportState {
  final String message;
  const CandidateReportError(this.message);
  @override
  List<Object?> get props => [message];
}

class CandidateReportCubit extends Cubit<CandidateReportState> {
  final OrchestrationRepository orchestrationRepository;
  final RecruitmentRepository recruitmentRepository;

  CandidateReportCubit({
    required this.orchestrationRepository,
    required this.recruitmentRepository,
  }) : super(CandidateReportInitial());

  Future<void> loadCandidateReport({
    required String sessionId,
    required String candidateId,
    required CandidateStatus currentStatus,
  }) async {
    emit(CandidateReportLoading());
    
    final reportResult = await orchestrationRepository.getCandidateReport(candidateId);
    final resultsResult = await orchestrationRepository.getAgentResults(sessionId, candidateId);

    reportResult.fold(
      (failure) => emit(CandidateReportError(failure.message)),
      (report) {
        resultsResult.fold(
          (failure) => emit(CandidateReportError(failure.message)),
          (results) {
            emit(CandidateReportLoaded(
              report: report,
              agentResults: results,
              candidateStatus: currentStatus,
            ));
          },
        );
      },
    );
  }

  Future<void> updateCandidateDecision(String candidateId, CandidateStatus status) async {
    final currentState = state;
    if (currentState is! CandidateReportLoaded) return;

    final result = await recruitmentRepository.updateCandidateStatus(candidateId, status);
    
    result.fold(
      (failure) => emit(CandidateReportError(failure.message)),
      (_) {
        emit(currentState.copyWith(candidateStatus: status));
      },
    );
  }
}
