import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import 'saved_jobs_event.dart';
import 'saved_jobs_state.dart';
import 'saved_jobs_event.dart';
import 'saved_jobs_state.dart';

// BLoC
class SavedJobsBloc extends Bloc<SavedJobsEvent, SavedJobsState> {
  final JobRepository jobRepository;

  SavedJobsBloc({required this.jobRepository}) : super(SavedJobsState()) {
    on<LoadSavedJobs>(_onLoadSavedJobs);
    on<RemoveSavedJob>(_onRemoveSavedJob);
  }

  Future<void> _onLoadSavedJobs(
    LoadSavedJobs event,
    Emitter<SavedJobsState> emit,
  ) async {
    emit(state.copyWith(status: SavedJobsStatus.loading));

    final result = await jobRepository.getSavedJobs();

    result.fold(
      (failure) => emit(
        state.copyWith(status: SavedJobsStatus.error, message: failure.message),
      ),
      (jobs) =>
          emit(state.copyWith(status: SavedJobsStatus.loaded, jobs: jobs)),
    );
  }

  Future<void> _onRemoveSavedJob(
    RemoveSavedJob event,
    Emitter<SavedJobsState> emit,
  ) async {
    await jobRepository.unsaveJob(event.jobId);

    final updatedJobs = state.jobs.where((j) => j.id != event.jobId).toList();
    emit(state.copyWith(jobs: updatedJobs));
  }
}
