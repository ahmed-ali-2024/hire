import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_cvs_usecase.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final UploadCVsUseCase uploadCVsUseCase;

  FileUploadCubit({
    required this.uploadCVsUseCase,
  }) : super(FileUploadInitial());

  Future<void> pickAndUploadCVs(String sessionId) async {
    emit(FileUploadPicking());
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        emit(FileUploadInitial());
        return;
      }

      emit(const FileUploadParsing(0, 1));
      
      final uploadResult = await uploadCVsUseCase(UploadCVsParams(
        sessionId: sessionId,
        files: result.files,
      ));

      uploadResult.fold(
        (failure) => emit(FileUploadError(failure.message)),
        (candidates) => emit(FileUploadSuccess(candidates)),
      );
    } catch (e) {
      emit(FileUploadError(e.toString()));
    }
  }

  void reset() {
    emit(FileUploadInitial());
  }
}
