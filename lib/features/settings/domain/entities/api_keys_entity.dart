import 'package:hire/core/usecases/base_entity.dart';

class ApiKeysEntity extends BaseEntity {
  final String id;
  final String userId;
  final String aimlApiKey;
  final String featherlessKey;
  final String bandApiKey;
  final String bandApiUrl;
  final DateTime updatedAt;

  const ApiKeysEntity({
    required this.id,
    required this.userId,
    required this.aimlApiKey,
    required this.featherlessKey,
    required this.bandApiKey,
    required this.bandApiUrl,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        aimlApiKey,
        featherlessKey,
        bandApiKey,
        bandApiUrl,
        updatedAt,
      ];
}
