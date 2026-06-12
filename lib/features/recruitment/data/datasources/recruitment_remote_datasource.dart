import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recruitment_session_model.dart';
import '../models/candidate_model.dart';

abstract class RecruitmentRemoteDataSource {
  Future<RecruitmentSessionModel> createSession({
    required String userId,
    required String jobTitle,
    required String jobDescription,
  });

  Future<List<RecruitmentSessionModel>> getSessions(String userId);

  Future<void> addCandidate(CandidateModel candidate);

  Future<List<CandidateModel>> getCandidates(String sessionId);
}

class RecruitmentRemoteDataSourceImpl implements RecruitmentRemoteDataSource {
  final SupabaseClient supabaseClient;

  RecruitmentRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<RecruitmentSessionModel> createSession({
    required String userId,
    required String jobTitle,
    required String jobDescription,
  }) async {
    final response = await supabaseClient.from('recruitment_sessions').insert({
      'user_id': userId,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'status': 'pending',
      'candidates_count': 0,
    }).select().single();
    
    return RecruitmentSessionModel.fromJson(response);
  }

  @override
  Future<List<RecruitmentSessionModel>> getSessions(String userId) async {
    final response = await supabaseClient
        .from('recruitment_sessions')
        .select()
        .eq('user_id', userId);
    
    return (response as List)
        .map((json) => RecruitmentSessionModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> addCandidate(CandidateModel candidate) async {
    await supabaseClient.from('candidates').insert(candidate.toJson());
  }

  @override
  Future<List<CandidateModel>> getCandidates(String sessionId) async {
    final response = await supabaseClient
        .from('candidates')
        .select()
        .eq('session_id', sessionId);
    
    return (response as List)
        .map((json) => CandidateModel.fromJson(json))
        .toList();
  }
}
