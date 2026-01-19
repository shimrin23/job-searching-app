import 'package:equatable/equatable.dart';

abstract class SavedJobsEvent extends Equatable {
  const SavedJobsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedJobs extends SavedJobsEvent {}

class RemoveSavedJob extends SavedJobsEvent {
  final String jobId;

  const RemoveSavedJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class LoadAppliedJobs extends SavedJobsEvent {}
