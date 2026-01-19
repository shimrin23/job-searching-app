import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/saved_jobs/saved_jobs_bloc.dart';
import '../../../logic/saved_jobs/saved_jobs_event.dart';
import '../../../logic/saved_jobs/saved_jobs_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/job_card.dart';
import '../../../logic/job/job_bloc.dart';
import '../../../logic/job/job_event.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedJobsBloc>().add(LoadSavedJobs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: BlocBuilder<SavedJobsBloc, SavedJobsState>(
        builder: (context, state) {
          if (state.status == SavedJobsStatus.loading) {
            return const LoadingIndicator();
          }

          if (state.status == SavedJobsStatus.error) {
            return ErrorView(
              message: state.message ?? 'Failed to load saved jobs',
              onRetry: () {
                context.read<SavedJobsBloc>().add(LoadSavedJobs());
              },
            );
          }

          if (state.jobs.isEmpty) {
            return const EmptyView(
              message: 'No saved jobs yet\nStart bookmarking jobs you like!',
              icon: Icons.bookmark_border,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SavedJobsBloc>().add(LoadSavedJobs());
            },
            child: ListView.builder(
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                final job = state.jobs[index];
                return JobCard(
                  job: job,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/job-details',
                      arguments: job,
                    );
                  },
                  onSave: () {
                    context.read<SavedJobsBloc>().add(RemoveSavedJob(job.id));
                    context.read<JobBloc>().add(ToggleSaveJob(job.id));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
