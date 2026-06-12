import '../../domain/entities/recruitment_session_entity.dart';

class RecruitmentSessionModel extends RecruitmentSessionEntity {
  const RecruitmentSessionModel({
    required super.id,
    required super.userId,
    required super.jobTitle,
    required super.jobDescription,
    required super.status,
    super.bandRoomId,
    required super.candidatesCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RecruitmentSessionModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jobTitle: json['job_title'] as String,
      jobDescription: json['job_description'] as String,
      status: SessionStatus.values.byName(json['status'] as String),
      bandRoomId: json['band_room_id'] as String?,
      candidatesCount: json['candidates_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'status': status.name,
      'band_room_id': bandRoomId,
      'candidates_count': candidatesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
