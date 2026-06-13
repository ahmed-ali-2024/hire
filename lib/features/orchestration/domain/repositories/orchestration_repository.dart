import 'package:fpdart/fpdart.dart';
import 'package:hire/core/error/failures.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:hire/features/settings/domain/entities/api_keys_entity.dart';
import '../entities/agent_result_entity.dart';
import '../entities/conflict_resolution_entity.dart';
import '../entities/final_report_entity.dart';
import '../entities/band_message_entity.dart';

abstract class OrchestrationRepository {
  Future<Either<Failure, AgentResultEntity>> runScreeningAgent({
    required CandidateEntity candidate,
    required String jobDescription,
    required ApiKeysEntity apiKeys,
  });

  Future<Either<Failure, AgentResultEntity>> runAdversarialReview({
    required CandidateEntity candidate,
    required AgentResultEntity screeningResult,
    required ApiKeysEntity apiKeys,
  });

  Future<Either<Failure, ConflictResolutionEntity>> resolveConflict({
    required String candidateId,
    required AgentResultEntity screeningResult,
    required AgentResultEntity reviewResult,
  });

  Future<Either<Failure, AgentResultEntity>> runInterviewAgent({
    required CandidateEntity candidate,
    required List<String> skills,
    required String experienceLevel,
    required ApiKeysEntity apiKeys,
  });

  Future<Either<Failure, AgentResultEntity>> runCulturalAssessment({
    required CandidateEntity candidate,
    required ApiKeysEntity apiKeys,
  });

  Future<Either<Failure, FinalReportEntity>> runCoordinationAgent({
    required String candidateId,
    required AgentResultEntity interviewResult,
    required AgentResultEntity culturalResult,
    required ConflictResolutionEntity conflictResolution,
    required ApiKeysEntity apiKeys,
  });

  Future<Either<Failure, Unit>> saveAgentResult(AgentResultEntity result);

  Future<Either<Failure, Unit>> saveFinalReport(FinalReportEntity report);

  Future<Either<Failure, Unit>> updateCandidateDecision(String candidateId, CandidateStatus status);

  Future<Either<Failure, List<BandMessageEntity>>> getBandMessages(String sessionId, String candidateId);

  Future<Either<Failure, List<FinalReportEntity>>> getFinalReports(String sessionId);

  Future<Either<Failure, FinalReportEntity>> getCandidateReport(String candidateId);

  Future<Either<Failure, List<AgentResultEntity>>> getAgentResults(String sessionId, String candidateId);
}
