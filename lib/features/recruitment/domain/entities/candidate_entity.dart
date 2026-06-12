import 'package:hire/core/usecases/base_entity.dart';

enum CandidateStatus {
  pending,
  analyzing,
  analyzed,
  accepted,
  rejected,
  reviewRequested
}

class CandidateEntity extends BaseEntity {
  final String id;
  final String sessionId;
  final String name;
  final String cvText;
  final String fileName;
  final double? overallScore;
  final CandidateStatus status;
  final DateTime createdAt;

  const CandidateEntity({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.cvText,
    required this.fileName,
    this.overallScore,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        name,
        cvText,
        fileName,
        overallScore,
        status,
        createdAt,
      ];
}
