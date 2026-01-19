import 'package:equatable/equatable.dart';

enum JobType { fullTime, partTime, contract, internship, temporary }

enum WorkLocation { onsite, remote, hybrid }

class Job extends Equatable {
  final String id;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final String location;
  final WorkLocation workLocation;
  final JobType jobType;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> benefits;
  final String? salaryRange;
  final String? experienceLevel;
  final List<String> skills;
  final String? applyUrl;
  final DateTime postedDate;
  final DateTime? deadline;
  final bool isSaved;
  final bool isApplied;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    required this.location,
    this.workLocation = WorkLocation.onsite,
    this.jobType = JobType.fullTime,
    required this.description,
    this.responsibilities = const [],
    this.requirements = const [],
    this.benefits = const [],
    this.salaryRange,
    this.experienceLevel,
    this.skills = const [],
    this.applyUrl,
    required this.postedDate,
    this.deadline,
    this.isSaved = false,
    this.isApplied = false,
  });

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogoUrl,
    String? location,
    WorkLocation? workLocation,
    JobType? jobType,
    String? description,
    List<String>? responsibilities,
    List<String>? requirements,
    List<String>? benefits,
    String? salaryRange,
    String? experienceLevel,
    List<String>? skills,
    String? applyUrl,
    DateTime? postedDate,
    DateTime? deadline,
    bool? isSaved,
    bool? isApplied,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      location: location ?? this.location,
      workLocation: workLocation ?? this.workLocation,
      jobType: jobType ?? this.jobType,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      salaryRange: salaryRange ?? this.salaryRange,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skills: skills ?? this.skills,
      applyUrl: applyUrl ?? this.applyUrl,
      postedDate: postedDate ?? this.postedDate,
      deadline: deadline ?? this.deadline,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    company,
    companyLogoUrl,
    location,
    workLocation,
    jobType,
    description,
    responsibilities,
    requirements,
    benefits,
    salaryRange,
    experienceLevel,
    skills,
    applyUrl,
    postedDate,
    deadline,
    isSaved,
    isApplied,
  ];
}
