import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire/core/di/injection_container.dart' as di;
import 'package:hire/core/l10n/app_localizations.dart';
import 'package:hire/features/recruitment/domain/usecases/create_session_usecase.dart';
import 'package:hire/features/recruitment/domain/usecases/upload_cvs_usecase.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/recruitment_cubit.dart';
import '../cubit/file_upload_cubit.dart';

class NewRecruitmentPage extends StatefulWidget {
  const NewRecruitmentPage({super.key});

  @override
  State<NewRecruitmentPage> createState() => _NewRecruitmentPageState();
}

class _NewRecruitmentPageState extends State<NewRecruitmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _submit(BuildContext context, String userId) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one CV')),
        );
        return;
      }

      final title = _titleController.text.trim();
      final desc = _descController.text.trim();

      setState(() => _isLoading = true);

      final recruitmentCubit = context.read<RecruitmentCubit>();
      final fileUploadCubit = context.read<FileUploadCubit>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        // Step 1: Create session
        final sessionResult = await recruitmentCubit.createSessionUseCase(CreateSessionParams(
          userId: userId,
          jobTitle: title,
          jobDescription: desc,
        ));

        String? errorMessage;
        bool success = false;

        sessionResult.fold(
          (failure) {
            errorMessage = failure.message;
          },
          (session) {},
        );

        if (errorMessage != null) {
          if (mounted) setState(() => _isLoading = false);
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMessage!)));
          return;
        }

        // Extract session from result
        final session = sessionResult.getOrElse((failure) => throw Exception(failure.message));

        // Step 2: Update session status
        await Supabase.instance.client
            .from('recruitment_sessions')
            .update({'status': 'analyzing'})
            .eq('id', session.id);

        // Step 3: Upload and parse CVs
        final uploadResult = await fileUploadCubit.uploadCVsUseCase(UploadCVsParams(
          sessionId: session.id,
          files: _selectedFiles,
        ));

        if (mounted) setState(() => _isLoading = false);

        uploadResult.fold(
          (failure) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          },
          (candidates) {
            success = true;
            recruitmentCubit.loadSessions(userId);
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Session created and CVs parsed successfully!')),
            );
          },
        );

        if (success && mounted) {
          context.go('/app/dashboard');
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => di.sl<FileUploadCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.newRecruitment),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                    shadowColor: theme.shadowColor.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.newRecruitment,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Define the job requirements and upload candidates CVs in PDF format to start the multi-agent screening process.',
                            ),
                            const SizedBox(height: 32),

                            // Job Title
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: l10n.jobTitle,
                                prefixIcon: const Icon(Icons.work_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter job title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Job Description
                            TextFormField(
                              controller: _descController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                labelText: l10n.jobDescription,
                                alignLabelWithHint: true,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 90.0),
                                  child: Icon(Icons.description_outlined),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter job description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // File Uploader Area
                            GestureDetector(
                              onTap: _pickFiles,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.4),
                                    style: BorderStyle.solid,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.colorScheme.primary.withOpacity(0.02),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 48,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.uploadCVs,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Upload candidates CVs (PDF only)'),
                                  ],
                                ),
                              ),
                            ),

                            // Selected Files List
                            if (_selectedFiles.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Selected Files (${_selectedFiles.length})',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _selectedFiles.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final file = _selectedFiles[index];
                                    return ListTile(
                                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                      title: Text(file.name),
                                      subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            _selectedFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),

                            // Action Buttons
                            if (_isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Processing CVs...'),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/app/dashboard'),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () => _submit(context, userId),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(l10n.startAnalysis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
