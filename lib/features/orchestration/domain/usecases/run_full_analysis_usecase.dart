import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:hire/features/recruitment/domain/entities/candidate_entity.dart';
import 'package:hire/features/settings/domain/entities/api_keys_entity.dart';
import '../entities/final_report_entity.dart';
import '../repositories/orchestration_repository.dart';

class RunFullAnalysisParams {
  final String sessionId;
  final String jobDescription;
  final List<CandidateEntity> candidates;
  final ApiKeysEntity apiKeys;

  const RunFullAnalysisParams({
    required this.sessionId,
    required this.jobDescription,
    required this.candidates,
    required this.apiKeys,
  });
}

class RunFullAnalysisUseCase implements UseCase<List<FinalReportEntity>, RunFullAnalysisParams> {
  final OrchestrationRepository repository;
  RunFullAnalysisUseCase(this.repository);

  @override
  Future<Either<Failure, List<FinalReportEntity>>> call(RunFullAnalysisParams params) async {
    final List<FinalReportEntity> reports = [];
    
    for (final candidate in params.candidates) {
      // 1. Screening
      final screeningResult = await repository.runScreeningAgent(
        candidate: candidate,
        jobDescription: params.jobDescription,
        apiKeys: params.apiKeys,
      );

      if (screeningResult.isLeft()) return Left(AgentFailure("Screening failed for ${candidate.name}"));
      final screening = screeningResult.getOrElse((l) => throw Exception());

      // 2. Adversarial Review
      final reviewResult = await repository.runAdversarialReview(
        candidate: candidate,
        screeningResult: screening,
        apiKeys: params.apiKeys,
      );
      if (reviewResult.isLeft()) return Left(AgentFailure("Review failed for ${candidate.name}"));
      final review = reviewResult.getOrElse((l) => throw Exception());

      // 3. Resolve Conflict
      final conflictResult = await repository.resolveConflict(
        candidateId: candidate.id,
        screeningResult: screening,
        reviewResult: review,
      );
      if (conflictResult.isLeft()) return Left(AgentFailure("Conflict resolution failed for ${candidate.name}"));
      final conflict = conflictResult.getOrElse((l) => throw Exception());

      // 4. Technical Interview
      final interviewResult = await repository.runInterviewAgent(
        candidate: candidate,
        skills: [], // Logic to extract from screening
        experienceLevel: "Mid", // Placeholder
        apiKeys: params.apiKeys,
      );
      if (interviewResult.isLeft()) return Left(AgentFailure("Interview failed for ${candidate.name}"));
      final interview = interviewResult.getOrElse((l) => throw Exception());

      // 5. Cultural Assessment
      final culturalResult = await repository.runCulturalAssessment(
        candidate: candidate,
        apiKeys: params.apiKeys,
      );
      if (culturalResult.isLeft()) return Left(AgentFailure("Cultural assessment failed for ${candidate.name}"));
      final cultural = culturalResult.getOrElse((l) => throw Exception());

      // 6. Coordination
      final finalReportResult = await repository.runCoordinationAgent(
        candidateId: candidate.id,
        interviewResult: interview,
        culturalResult: cultural,
        conflictResolution: conflict,
        apiKeys: params.apiKeys,
      );
      if (finalReportResult.isLeft()) return Left(AgentFailure("Coordination failed for ${candidate.name}"));
      final report = finalReportResult.getOrElse((l) => throw Exception());
      
      reports.add(report);
    }

    return Right(reports);
  }
}
