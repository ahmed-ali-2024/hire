import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/recruitment_cubit.dart';

class RecruitmentPage extends StatelessWidget {
  const RecruitmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => sl<RecruitmentCubit>()..loadSessions(user.id),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recruitment Sessions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
        body: BlocBuilder<RecruitmentCubit, RecruitmentState>(
          builder: (context, state) {
            if (state is RecruitmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecruitmentLoaded) {
              return ListView.builder(
                itemCount: state.sessions.length,
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return ListTile(
                    title: Text(session.jobTitle),
                    subtitle: Text(session.status.name),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              );
            } else if (state is RecruitmentError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No sessions found.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateSessionDialog(context, user.id),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, String userId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Job Title')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Job Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<RecruitmentCubit>().createSession(
                userId: userId,
                jobTitle: titleController.text,
                jobDescription: descController.text,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
