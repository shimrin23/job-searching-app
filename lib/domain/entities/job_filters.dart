import 'package:equatable/equatable.dart';
import 'job.dart';

class JobFilters extends Equatable {
  final String? searchQuery;
  final List<JobType>? jobTypes;
  final List<WorkLocation>? workLocations;
  final String? location;
  final String? experienceLevel;
  final List<String>? skills;
  final DateTime? postedAfter;

  const JobFilters({
    this.searchQuery,
    this.jobTypes,
    this.workLocations,
    this.location,
    this.experienceLevel,
    this.skills,
    this.postedAfter,
  });

  JobFilters copyWith({
    String? searchQuery,
    List<JobType>? jobTypes,
    List<WorkLocation>? workLocations,
    String? location,
    String? experienceLevel,
    List<String>? skills,
    DateTime? postedAfter,
  }) {
    return JobFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      jobTypes: jobTypes ?? this.jobTypes,
      workLocations: workLocations ?? this.workLocations,
      location: location ?? this.location,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skills: skills ?? this.skills,
      postedAfter: postedAfter ?? this.postedAfter,
    );
  }

  bool get isEmpty =>
      searchQuery == null &&
      (jobTypes == null || jobTypes!.isEmpty) &&
      (workLocations == null || workLocations!.isEmpty) &&
      location == null &&
      experienceLevel == null &&
      (skills == null || skills!.isEmpty) &&
      postedAfter == null;

  @override
  List<Object?> get props => [
    searchQuery,
    jobTypes,
    workLocations,
    location,
    experienceLevel,
    skills,
    postedAfter,
  ];
}
