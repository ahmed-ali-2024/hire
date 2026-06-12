import 'package:hire/core/usecases/base_entity.dart';
import 'agent_result_entity.dart';

enum BandMessageType {
  contextHandoff,
  reviewRequest,
  reviewResult,
  finalEvaluation,
  coordinatorSync
}

class BandMessageEntity extends BaseEntity {
  final String id;
  final String roomId;
  final String sessionId;
  final String candidateId;
  final BandMessageType messageType;
  final AgentType senderAgent;
  final AgentType receiverAgent;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const BandMessageEntity({
    required this.id,
    required this.roomId,
    required this.sessionId,
    required this.candidateId,
    required this.messageType,
    required this.senderAgent,
    required this.receiverAgent,
    required this.payload,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        sessionId,
        candidateId,
        messageType,
        senderAgent,
        receiverAgent,
        payload,
        createdAt,
      ];
}
