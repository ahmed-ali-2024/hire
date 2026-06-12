import 'package:hire/core/usecases/base_entity.dart';
import 'agent_result_entity.dart';

class ConflictResolutionEntity extends BaseEntity {
  final String candidateId;
  final double screeningScore;
  final double reviewScore;
  final double finalScore;
  final bool hasConflict;
  final String? conflictNote;
  final AgentRecommendation finalRecommendation;

  const ConflictResolutionEntity({
    required this.candidateId,
    required this.screeningScore,
    required this.reviewScore,
    required this.finalScore,
    required this.hasConflict,
    this.conflictNote,
    required this.finalRecommendation,
  });

  @override
  List<Object?> get props => [
        candidateId,
        screeningScore,
        reviewScore,
        finalScore,
        hasConflict,
        conflictNote,
        finalRecommendation,
      ];
}
