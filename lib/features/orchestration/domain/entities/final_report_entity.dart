import 'package:hire/core/usecases/base_entity.dart';
import 'agent_result_entity.dart';

class FinalReportEntity extends BaseEntity {
  final String id;
  final String sessionId;
  final String candidateId;
  final double screeningScore;
  final double technicalScore;
  final double culturalScore;
  final double overallScore;
  final bool hasConflict;
  final String? conflictNote;
  final AgentRecommendation finalRecommendation;
  final String summaryNotes;
  final DateTime createdAt;

  const FinalReportEntity({
    required this.id,
    required this.sessionId,
    required this.candidateId,
    required this.screeningScore,
    required this.technicalScore,
    required this.culturalScore,
    required this.overallScore,
    required this.hasConflict,
    this.conflictNote,
    required this.finalRecommendation,
    required this.summaryNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        candidateId,
        screeningScore,
        technicalScore,
        culturalScore,
        overallScore,
        hasConflict,
        conflictNote,
        finalRecommendation,
        summaryNotes,
        createdAt,
      ];
}
