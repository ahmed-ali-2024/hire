import 'package:hire/core/usecases/base_entity.dart';

enum SessionStatus { pending, analyzing, completed, failed }

class RecruitmentSessionEntity extends BaseEntity {
  final String id;
  final String userId;
  final String jobTitle;
  final String jobDescription;
  final SessionStatus status;
  final String? bandRoomId;
  final int candidatesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecruitmentSessionEntity({
    required this.id,
    required this.userId,
    required this.jobTitle,
    required this.jobDescription,
    required this.status,
    this.bandRoomId,
    required this.candidatesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        jobTitle,
        jobDescription,
        status,
        bandRoomId,
        candidatesCount,
        createdAt,
        updatedAt,
      ];
}
