import 'package:equatable/equatable.dart';
import '../../domain/entities/candidate_entity.dart';

abstract class FileUploadState extends Equatable {
  const FileUploadState();

  @override
  List<Object?> get props => [];
}

class FileUploadInitial extends FileUploadState {}

class FileUploadPicking extends FileUploadState {}

class FileUploadParsing extends FileUploadState {
  final int current;
  final int total;

  const FileUploadParsing(this.current, this.total);

  @override
  List<Object?> get props => [current, total];
}

class FileUploadSuccess extends FileUploadState {
  final List<CandidateEntity> candidates;

  const FileUploadSuccess(this.candidates);

  @override
  List<Object?> get props => [candidates];
}

class FileUploadError extends FileUploadState {
  final String message;

  const FileUploadError(this.message);

  @override
  List<Object?> get props => [message];
}
