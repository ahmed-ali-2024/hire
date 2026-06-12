import '../../domain/entities/api_keys_entity.dart';

class ApiKeysModel extends ApiKeysEntity {
  const ApiKeysModel({
    required super.id,
    required super.userId,
    required super.aimlApiKey,
    required super.featherlessKey,
    required super.bandApiKey,
    required super.bandApiUrl,
    required super.updatedAt,
  });

  factory ApiKeysModel.fromJson(Map<String, dynamic> json) {
    return ApiKeysModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      aimlApiKey: json['aiml_api_key'] as String,
      featherlessKey: json['featherless_key'] as String,
      bandApiKey: json['band_api_key'] as String,
      bandApiUrl: json['band_api_url'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'aiml_api_key': aimlApiKey,
      'featherless_key': featherlessKey,
      'band_api_key': bandApiKey,
      'band_api_url': bandApiUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
