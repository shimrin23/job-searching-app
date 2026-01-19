import 'package:equatable/equatable.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/job_filters.dart';

enum JobStatus { initial, loading, loaded, error, refreshing }

class JobState extends Equatable {
  final JobStatus status;
  final List<Job> jobs;
  final String? message;
  final int currentPage;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final JobFilters? filters;

  const JobState({
    this.status = JobStatus.initial,
    this.jobs = const [],
    this.message,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.filters,
  });

  JobState copyWith({
    JobStatus? status,
    List<Job>? jobs,
    String? message,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingMore,
    JobFilters? filters,
  }) {
    return JobState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      message: message ?? this.message,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [
    status,
    jobs,
    message,
    currentPage,
    hasReachedMax,
    isFetchingMore,
    filters,
  ];
}
