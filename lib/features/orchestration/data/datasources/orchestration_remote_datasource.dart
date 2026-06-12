import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire/features/orchestration/data/models/agent_result_model.dart';
import 'package:hire/features/orchestration/data/models/final_report_model.dart';

abstract class OrchestrationRemoteDataSource {
  /// Invokes the orchestrate-session Edge Function
  Future<Map<String, dynamic>> orchestrateSession({
    required String sessionId,
    required String jobDescription,
    required String jobTitle,
    required List<Map<String, String>> candidates,
  });

  Future<List<AgentResultModel>> getAgentResults(String sessionId, String candidateId);
  Future<FinalReportModel?> getFinalReport(String candidateId);
  Future<List<FinalReportModel>> getSessionReports(String sessionId);
  Future<List<Map<String, dynamic>>> getBandMessages(String sessionId, String? candidateId);
}

class OrchestrationRemoteDataSourceImpl implements OrchestrationRemoteDataSource {
  final SupabaseClient supabaseClient;

  OrchestrationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Map<String, dynamic>> orchestrateSession({
    required String sessionId,
    required String jobDescription,
    required String jobTitle,
    required List<Map<String, String>> candidates,
  }) async {
    final response = await supabaseClient.functions.invoke(
      'orchestrate-session',
      body: {
        'sessionId': sessionId,
        'jobDescription': jobDescription,
        'jobTitle': jobTitle,
        'candidates': candidates,
      },
    );
    if (response.data == null) {
      throw Exception('Edge Function returned null response');
    }
    final data = response.data as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    return data;
  }

  @override
  Future<List<AgentResultModel>> getAgentResults(String sessionId, String candidateId) async {
    final response = await supabaseClient
        .from('agent_results')
        .select()
        .eq('session_id', sessionId)
        .eq('candidate_id', candidateId)
        .order('created_at');
    return (response as List).map((e) => AgentResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<FinalReportModel?> getFinalReport(String candidateId) async {
    final response = await supabaseClient
        .from('final_reports')
        .select()
        .eq('candidate_id', candidateId)
        .maybeSingle();
    if (response == null) return null;
    return FinalReportModel.fromJson(response);
  }

  @override
  Future<List<FinalReportModel>> getSessionReports(String sessionId) async {
    final response = await supabaseClient
        .from('final_reports')
        .select()
        .eq('session_id', sessionId)
        .order('created_at');
    return (response as List).map((e) => FinalReportModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getBandMessages(String sessionId, String? candidateId) async {
    var query = supabaseClient
        .from('band_messages_log')
        .select()
        .eq('session_id', sessionId);
    if (candidateId != null) {
      query = query.eq('candidate_id', candidateId);
    }
    final response = await query.order('created_at');
    return (response as List).cast<Map<String, dynamic>>();
  }
}
