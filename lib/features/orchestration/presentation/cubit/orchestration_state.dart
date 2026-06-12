import 'package:equatable/equatable.dart';
import 'package:hire/features/orchestration/domain/entities/agent_result_entity.dart';
import 'package:hire/features/orchestration/domain/entities/final_report_entity.dart';

abstract class OrchestrationState extends Equatable {
  const OrchestrationState();
  @override
  List<Object?> get props => [];
}

class OrchestrationInitial extends OrchestrationState {
  const OrchestrationInitial();
}

class OrchestrationAnalyzing extends OrchestrationState {
  final String currentStep;
  final int completedSteps;
  final int totalSteps;
  final String candidateName;

  const OrchestrationAnalyzing({
    required this.currentStep,
    required this.completedSteps,
    required this.totalSteps,
    required this.candidateName,
  });

  double get progress => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  @override
  List<Object?> get props => [currentStep, completedSteps, totalSteps, candidateName];
}

class OrchestrationAgentCompleted extends OrchestrationState {
  final String agentName;
  final AgentResultEntity result;
  final int completedSteps;
  final int totalSteps;
  final String candidateName;

  const OrchestrationAgentCompleted({
    required this.agentName,
    required this.result,
    required this.completedSteps,
    required this.totalSteps,
    required this.candidateName,
  });

  double get progress => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  @override
  List<Object?> get props => [agentName, result, completedSteps, totalSteps, candidateName];
}

class OrchestrationCompleted extends OrchestrationState {
  final List<FinalReportEntity> reports;
  final String bandRoomId;
  final int processedCandidates;

  const OrchestrationCompleted({
    required this.reports,
    required this.bandRoomId,
    required this.processedCandidates,
  });

  @override
  List<Object?> get props => [reports, bandRoomId, processedCandidates];
}

class OrchestrationError extends OrchestrationState {
  final String message;
  const OrchestrationError(this.message);

  @override
  List<Object?> get props => [message];
}
