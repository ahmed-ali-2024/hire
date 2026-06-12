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

  Future<RecruitmentSessionModel> getSessionById(String id);

  Future<void> updateSessionStatus(String id, String status);

  Future<void> updateSessionBandRoom(String id, String bandRoomId);

  Future<void> addCandidate(CandidateModel candidate);

  Future<List<CandidateModel>> getCandidates(String sessionId);

  Future<void> updateCandidateStatus(String candidateId, String status);

  Future<void> updateCandidateScore(String candidateId, double score);
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
  Future<RecruitmentSessionModel> getSessionById(String id) async {
    final response = await supabaseClient
        .from('recruitment_sessions')
        .select()
        .eq('id', id)
        .single();
    return RecruitmentSessionModel.fromJson(response);
  }

  @override
  Future<void> updateSessionStatus(String id, String status) async {
    await supabaseClient
        .from('recruitment_sessions')
        .update({'status': status})
        .eq('id', id);
  }

  @override
  Future<void> updateSessionBandRoom(String id, String bandRoomId) async {
    await supabaseClient
        .from('recruitment_sessions')
        .update({'band_room_id': bandRoomId})
        .eq('id', id);
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

  @override
  Future<void> updateCandidateStatus(String candidateId, String status) async {
    await supabaseClient
        .from('candidates')
        .update({'status': status})
        .eq('id', candidateId);
  }

  @override
  Future<void> updateCandidateScore(String candidateId, double score) async {
    await supabaseClient
        .from('candidates')
        .update({'overall_score': score})
        .eq('id', candidateId);
  }
}
