import 'package:equatable/equatable.dart';
import '../../domain/entities/job.dart';

enum SavedJobsStatus { initial, loading, loaded, error }

class SavedJobsState extends Equatable {
  final SavedJobsStatus status;
  final List<Job> jobs;
  final String? message;

  const SavedJobsState({
    this.status = SavedJobsStatus.initial,
    this.jobs = const [],
    this.message,
  });

  SavedJobsState copyWith({
    SavedJobsStatus? status,
    List<Job>? jobs,
    String? message,
  }) {
    return SavedJobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, jobs, message];
}
