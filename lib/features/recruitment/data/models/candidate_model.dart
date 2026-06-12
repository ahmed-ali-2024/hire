import '../../domain/entities/candidate_entity.dart';

class CandidateModel extends CandidateEntity {
  const CandidateModel({
    required super.id,
    required super.sessionId,
    required super.name,
    required super.cvText,
    required super.fileName,
    super.overallScore,
    required super.status,
    required super.createdAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      name: json['name'] as String,
      cvText: json['cv_text'] as String,
      fileName: json['file_name'] as String,
      overallScore: (json['overall_score'] as num?)?.toDouble(),
      status: CandidateStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'name': name,
      'cv_text': cvText,
      'file_name': fileName,
      'overall_score': overallScore,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
