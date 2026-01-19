import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/job_repository.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository jobRepository;

  JobBloc({required this.jobRepository}) : super(const JobState()) {
    on<LoadJobs>(_onLoadJobs);
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchJobs>(_onSearchJobs);
    on<ApplyFilters>(_onApplyFilters);
    on<ToggleSaveJob>(_onToggleSaveJob);
    on<ApplyToJob>(_onApplyToJob);
    on<ClearCache>(_onClearCache);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          status: JobStatus.refreshing,
          currentPage: 1,
          filters: event.filters,
        ),
      );
    } else {
      emit(state.copyWith(status: JobStatus.loading, filters: event.filters));
    }

    final result = await jobRepository.getJobs(
      page: 1,
      filters: event.filters ?? state.filters,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: JobStatus.error, message: failure.message),
      ),
      (jobs) => emit(
        state.copyWith(
          status: JobStatus.loaded,
          jobs: jobs,
          currentPage: 1,
          hasReachedMax: jobs.length < 20,
        ),
      ),
    );
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<JobState> emit,
  ) async {
    if (state.hasReachedMax || state.isFetchingMore) return;

    emit(state.copyWith(isFetchingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await jobRepository.getJobs(
      page: nextPage,
      filters: state.filters,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isFetchingMore: false, message: failure.message)),
      (newJobs) {
        final allJobs = List.of(state.jobs)..addAll(newJobs);
        emit(
          state.copyWith(
            jobs: allJobs,
            currentPage: nextPage,
            hasReachedMax: newJobs.length < 20,
            isFetchingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onSearchJobs(SearchJobs event, Emitter<JobState> emit) async {
    emit(state.copyWith(status: JobStatus.loading));

    final result = await jobRepository.searchJobs(event.query);

    result.fold(
      (failure) => emit(
        state.copyWith(status: JobStatus.error, message: failure.message),
      ),
      (jobs) => emit(
        state.copyWith(
          status: JobStatus.loaded,
          jobs: jobs,
          currentPage: 1,
          hasReachedMax: true,
        ),
      ),
    );
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<JobState> emit,
  ) async {
    emit(
      state.copyWith(
        status: JobStatus.loading,
        filters: event.filters,
        currentPage: 1,
      ),
    );

    final result = await jobRepository.getJobs(page: 1, filters: event.filters);

    result.fold(
      (failure) => emit(
        state.copyWith(status: JobStatus.error, message: failure.message),
      ),
      (jobs) => emit(
        state.copyWith(
          status: JobStatus.loaded,
          jobs: jobs,
          hasReachedMax: jobs.length < 20,
        ),
      ),
    );
  }

  Future<void> _onToggleSaveJob(
    ToggleSaveJob event,
    Emitter<JobState> emit,
  ) async {
    final job = state.jobs.firstWhere((j) => j.id == event.jobId);

    if (job.isSaved) {
      await jobRepository.unsaveJob(event.jobId);
    } else {
      await jobRepository.saveJob(event.jobId);
    }

    final updatedJobs = state.jobs.map((j) {
      if (j.id == event.jobId) {
        return j.copyWith(isSaved: !j.isSaved);
      }
      return j;
    }).toList();

    emit(state.copyWith(jobs: updatedJobs));
  }

  Future<void> _onApplyToJob(ApplyToJob event, Emitter<JobState> emit) async {
    await jobRepository.applyToJob(event.jobId);

    final updatedJobs = state.jobs.map((j) {
      if (j.id == event.jobId) {
        return j.copyWith(isApplied: true);
      }
      return j;
    }).toList();

    emit(
      state.copyWith(
        jobs: updatedJobs,
        message: 'Application submitted successfully',
      ),
    );
  }

  Future<void> _onClearCache(ClearCache event, Emitter<JobState> emit) async {
    await jobRepository.clearCache();
    emit(state.copyWith(jobs: [], currentPage: 1, hasReachedMax: false));
  }
}
