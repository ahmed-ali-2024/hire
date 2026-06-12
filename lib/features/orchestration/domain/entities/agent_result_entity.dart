import '../../../core/usecases/base_entity.dart';

enum AgentType {
  screening,
  adversarialReview,
  technicalInterview,
  culturalAssessment,
  coordination
}

enum AgentRecommendation { accept, reject, maybe }

class AgentResultEntity extends BaseEntity {
  final String id;
  final String sessionId;
  final String candidateId;
  final AgentType agentType;
  final double score;
  final String summary;
  final AgentRecommendation recommendation;
  final Map<String, dynamic> rawData;
  final DateTime createdAt;

  const AgentResultEntity({
    required this.id,
    required this.sessionId,
    required this.candidateId,
    required this.agentType,
    required this.score,
    required this.summary,
    required this.recommendation,
    required this.rawData,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        candidateId,
        agentType,
        score,
        summary,
        recommendation,
        rawData,
        createdAt,
      ];
}
