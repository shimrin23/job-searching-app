import 'package:equatable/equatable.dart';
import '../../domain/entities/job_filters.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {
  final bool refresh;
  final JobFilters? filters;

  const LoadJobs({this.refresh = false, this.filters});

  @override
  List<Object?> get props => [refresh, filters];
}

class LoadNextPage extends JobEvent {}

class SearchJobs extends JobEvent {
  final String query;

  const SearchJobs(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilters extends JobEvent {
  final JobFilters filters;

  const ApplyFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class ToggleSaveJob extends JobEvent {
  final String jobId;

  const ToggleSaveJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ApplyToJob extends JobEvent {
  final String jobId;

  const ApplyToJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ClearCache extends JobEvent {}
