import 'package:fpdart/fpdart.dart';
import 'package:hire/core/error/failures.dart';
import 'package:hire/core/logger/app_logger.dart';
import 'package:hire/features/orchestration/data/datasources/orchestration_remote_datasource.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/band_message_entity.dart';
import 'package:hire/features/orchestration/domain/entities/conflict_resolution_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';
import 'package:hire/features/orchestration/domain/repositories/orchestration_repository.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:hire/features/settings/domain/entities/api_keys_entity.dart';

class OrchestrationRepositoryImpl implements OrchestrationRepository {
  final OrchestrationRemoteDataSource remoteDataSource;

  OrchestrationRepositoryImpl({required this.remoteDataSource});

  /// Triggers the full orchestration via Edge Function
  Future<Either<Failure, Map<String, dynamic>>> runOrchestration({
    required String sessionId,
    required String jobTitle,
    required String jobDescription,
    required List<CandidateEntity> candidates,
  }) async {
    try {
      final result = await remoteDataSource.orchestrateSession(
        sessionId: sessionId,
        jobDescription: jobDescription,
        jobTitle: jobTitle,
        candidates: candidates
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'cvText': c.cvText,
                  'fileName': c.fileName,
                })
            .toList(),
      );
      return Right(result);
    } catch (e) {
      AppLogger.instance.e('OrchestrationRepository.runOrchestration failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FinalReportEntity>>> getFinalReports(String sessionId) async {
    try {
      final reports = await remoteDataSource.getSessionReports(sessionId);
      return Right(reports);
    } catch (e) {
      AppLogger.instance.e('getFinalReports failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinalReportEntity>> getCandidateReport(String candidateId) async {
    try {
      final report = await remoteDataSource.getFinalReport(candidateId);
      if (report == null) return const Left(ServerFailure('Report not found'));
      return Right(report);
    } catch (e) {
      AppLogger.instance.e('getCandidateReport failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BandMessageEntity>>> getBandMessages(
      String sessionId, String candidateId) async {
    try {
      final messages = await remoteDataSource.getBandMessages(sessionId, candidateId);
      final entities = messages.map((m) {
        return BandMessageEntity(
          id: m['id'] as String? ?? '',
          roomId: m['room_id'] as String? ?? '',
          sessionId: m['session_id'] as String? ?? '',
          candidateId: m['candidate_id'] as String? ?? '',
          messageType: _parseMsgType(m['message_type'] as String? ?? ''),
          senderAgent: _parseAgentType(m['sender_agent'] as String? ?? ''),
          receiverAgent: _parseAgentType(m['receiver_agent'] as String? ?? ''),
          payload: (m['payload'] as Map<String, dynamic>?) ?? {},
          createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
      return Right(entities);
    } catch (e) {
      AppLogger.instance.e('getBandMessages failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Stubs for interface compliance (handled by Edge Function) ─────────
  @override
  Future<Either<Failure, AgentResultEntity>> runScreeningAgent({
    required CandidateEntity candidate,
    required String jobDescription,
    required ApiKeysEntity apiKeys,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, AgentResultEntity>> runAdversarialReview({
    required CandidateEntity candidate,
    required AgentResultEntity screeningResult,
    required ApiKeysEntity apiKeys,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, ConflictResolutionEntity>> resolveConflict({
    required String candidateId,
    required AgentResultEntity screeningResult,
    required AgentResultEntity reviewResult,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, AgentResultEntity>> runInterviewAgent({
    required CandidateEntity candidate,
    required List<String> skills,
    required String experienceLevel,
    required ApiKeysEntity apiKeys,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, AgentResultEntity>> runCulturalAssessment({
    required CandidateEntity candidate,
    required ApiKeysEntity apiKeys,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, FinalReportEntity>> runCoordinationAgent({
    required String candidateId,
    required AgentResultEntity interviewResult,
    required AgentResultEntity culturalResult,
    required ConflictResolutionEntity conflictResolution,
    required ApiKeysEntity apiKeys,
  }) async => const Left(ServerFailure('Use orchestrateSession via Edge Function'));

  @override
  Future<Either<Failure, Unit>> saveAgentResult(AgentResultEntity result) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> saveFinalReport(FinalReportEntity report) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> updateCandidateDecision(
      String candidateId, CandidateStatus status) async =>
      const Right(unit);

  // ─── Helpers ──────────────────────────────────────────────────────────
  static BandMessageType _parseMsgType(String v) {
    switch (v) {
      case 'reviewRequest':
        return BandMessageType.reviewRequest;
      case 'reviewResult':
        return BandMessageType.reviewResult;
      case 'finalEvaluation':
        return BandMessageType.finalEvaluation;
      case 'coordinatorSync':
        return BandMessageType.coordinatorSync;
      default:
        return BandMessageType.contextHandoff;
    }
  }

  static AgentType _parseAgentType(String v) {
    switch (v) {
      case 'adversarialReview':
        return AgentType.adversarialReview;
      case 'technicalInterview':
        return AgentType.technicalInterview;
      case 'culturalAssessment':
        return AgentType.culturalAssessment;
      case 'coordination':
        return AgentType.coordination;
      default:
        return AgentType.screening;
    }
  }
}
