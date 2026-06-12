import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/api_keys_model.dart';

abstract class SettingsRemoteDataSource {
  Future<void> saveApiKeys(ApiKeysModel keys);
  Future<ApiKeysModel> getApiKeys(String userId);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final SupabaseClient supabaseClient;

  SettingsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> saveApiKeys(ApiKeysModel keys) async {
    await supabaseClient.from('user_secrets').upsert(keys.toJson());
  }

  @override
  Future<ApiKeysModel> getApiKeys(String userId) async {
    final response = await supabaseClient
        .from('user_secrets')
        .select()
        .eq('user_id', userId)
        .single();
    
    return ApiKeysModel.fromJson(response);
  }
}
