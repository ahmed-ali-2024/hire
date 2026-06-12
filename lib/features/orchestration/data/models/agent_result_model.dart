import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';

class AgentResultModel extends AgentResultEntity {
  const AgentResultModel({
    required super.id,
    required super.sessionId,
    required super.candidateId,
    required super.agentType,
    required super.score,
    required super.summary,
    required super.recommendation,
    required super.rawData,
    required super.createdAt,
  });

  factory AgentResultModel.fromJson(Map<String, dynamic> json) {
    return AgentResultModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      candidateId: json['candidate_id'] as String,
      agentType: _parseAgentType(json['agent_type'] as String),
      score: (json['score'] as num).toDouble(),
      summary: json['summary'] as String,
      recommendation: _parseRecommendation(json['recommendation'] as String),
      rawData: (json['raw_data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'candidate_id': candidateId,
        'agent_type': agentType.name,
        'score': score,
        'summary': summary,
        'recommendation': recommendation.name,
        'raw_data': rawData,
        'created_at': createdAt.toIso8601String(),
      };

  static AgentType _parseAgentType(String value) {
    switch (value) {
      case 'screening':
        return AgentType.screening;
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

  static AgentRecommendation _parseRecommendation(String value) {
    switch (value) {
      case 'accept':
        return AgentRecommendation.accept;
      case 'reject':
        return AgentRecommendation.reject;
      default:
        return AgentRecommendation.maybe;
    }
  }
}
