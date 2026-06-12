import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';

class FinalReportModel extends FinalReportEntity {
  const FinalReportModel({
    required super.id,
    required super.sessionId,
    required super.candidateId,
    required super.screeningScore,
    required super.technicalScore,
    required super.culturalScore,
    required super.overallScore,
    required super.hasConflict,
    super.conflictNote,
    required super.finalRecommendation,
    required super.summaryNotes,
    required super.createdAt,
  });

  factory FinalReportModel.fromJson(Map<String, dynamic> json) {
    return FinalReportModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      candidateId: json['candidate_id'] as String,
      screeningScore: (json['screening_score'] as num).toDouble(),
      technicalScore: (json['technical_score'] as num).toDouble(),
      culturalScore: (json['cultural_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      hasConflict: json['has_conflict'] as bool? ?? false,
      conflictNote: json['conflict_note'] as String?,
      finalRecommendation: _parseRecommendation(json['final_recommendation'] as String),
      summaryNotes: json['summary_notes'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'candidate_id': candidateId,
        'screening_score': screeningScore,
        'technical_score': technicalScore,
        'cultural_score': culturalScore,
        'overall_score': overallScore,
        'has_conflict': hasConflict,
        'conflict_note': conflictNote,
        'final_recommendation': finalRecommendation.name,
        'summary_notes': summaryNotes,
        'created_at': createdAt.toIso8601String(),
      };

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
