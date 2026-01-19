import 'package:hive/hive.dart';
import '../../domain/entities/job.dart';

@HiveType(typeId: 1)
class JobModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String company;

  @HiveField(3)
  final String? companyLogoUrl;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final String workLocation;

  @HiveField(6)
  final String jobType;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final List<String> responsibilities;

  @HiveField(9)
  final List<String> requirements;

  @HiveField(10)
  final List<String> benefits;

  @HiveField(11)
  final String? salaryRange;

  @HiveField(12)
  final String? experienceLevel;

  @HiveField(13)
  final List<String> skills;

  @HiveField(14)
  final String? applyUrl;

  @HiveField(15)
  final DateTime postedDate;

  @HiveField(16)
  final DateTime? deadline;

  @HiveField(17)
  final bool isSaved;

  @HiveField(18)
  final bool isApplied;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    required this.location,
    this.workLocation = 'onsite',
    this.jobType = 'fullTime',
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

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Check if this is from The Muse API
    if (json.containsKey('name') && json.containsKey('company')) {
      return JobModel.fromMuseApi(json);
    }

    // Standard format
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      location: json['location'] as String,
      workLocation: json['workLocation'] as String? ?? 'onsite',
      jobType: json['jobType'] as String? ?? 'fullTime',
      description: json['description'] as String,
      responsibilities:
          (json['responsibilities'] as List<dynamic>?)?.cast<String>() ?? [],
      requirements:
          (json['requirements'] as List<dynamic>?)?.cast<String>() ?? [],
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      salaryRange: json['salaryRange'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      applyUrl: json['applyUrl'] as String?,
      postedDate: json['postedDate'] is String
          ? DateTime.parse(json['postedDate'])
          : (json['postedDate'] as DateTime),
      deadline: json['deadline'] != null
          ? (json['deadline'] is String
                ? DateTime.parse(json['deadline'])
                : (json['deadline'] as DateTime))
          : null,
      isSaved: json['isSaved'] as bool? ?? false,
      isApplied: json['isApplied'] as bool? ?? false,
    );
  }

  /// Parse job from The Muse API response
  factory JobModel.fromMuseApi(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>? ?? {};
    final locations = json['locations'] as List<dynamic>? ?? [];
    final categories = json['categories'] as List<dynamic>? ?? [];
    final levels = json['levels'] as List<dynamic>? ?? [];

    // Extract location
    String location = 'Remote';
    if (locations.isNotEmpty) {
      final firstLocation = locations[0] as Map<String, dynamic>;
      location = firstLocation['name'] as String? ?? 'Remote';
    }

    // Extract job type
    String jobType = 'fullTime';
    final publicationType = json['publication_date'] as String?;
    if (publicationType != null && publicationType.contains('internship')) {
      jobType = 'internship';
    }

    // Extract experience level
    String? experienceLevel;
    if (levels.isNotEmpty) {
      final level = levels[0] as Map<String, dynamic>;
      experienceLevel = level['name'] as String?;
    }

    // Extract skills from categories
    List<String> skills = [];
    if (categories.isNotEmpty) {
      skills = categories.map((cat) {
        final catMap = cat as Map<String, dynamic>;
        return catMap['name'] as String;
      }).toList();
    }

    return JobModel(
      id: json['id'].toString(),
      title: json['name'] as String,
      company: company['name'] as String? ?? 'Unknown Company',
      companyLogoUrl:
          (json['refs'] as Map<String, dynamic>?)?['logo_image'] as String?,
      location: location,
      workLocation: location.toLowerCase().contains('remote')
          ? 'remote'
          : 'onsite',
      jobType: jobType,
      description: json['contents'] as String? ?? '',
      responsibilities: [],
      requirements: [],
      benefits: [],
      salaryRange: null,
      experienceLevel: experienceLevel,
      skills: skills,
      applyUrl:
          (json['refs'] as Map<String, dynamic>?)?['landing_page'] as String?,
      postedDate: json['publication_date'] != null
          ? DateTime.parse(json['publication_date'])
          : DateTime.now(),
      deadline: null,
      isSaved: false,
      isApplied: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyLogoUrl': companyLogoUrl,
      'location': location,
      'workLocation': workLocation,
      'jobType': jobType,
      'description': description,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'benefits': benefits,
      'salaryRange': salaryRange,
      'experienceLevel': experienceLevel,
      'skills': skills,
      'applyUrl': applyUrl,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'isSaved': isSaved,
      'isApplied': isApplied,
    };
  }

  factory JobModel.fromEntity(Job job) {
    return JobModel(
      id: job.id,
      title: job.title,
      company: job.company,
      companyLogoUrl: job.companyLogoUrl,
      location: job.location,
      workLocation: _workLocationToString(job.workLocation),
      jobType: _jobTypeToString(job.jobType),
      description: job.description,
      responsibilities: job.responsibilities,
      requirements: job.requirements,
      benefits: job.benefits,
      salaryRange: job.salaryRange,
      experienceLevel: job.experienceLevel,
      skills: job.skills,
      applyUrl: job.applyUrl,
      postedDate: job.postedDate,
      deadline: job.deadline,
      isSaved: job.isSaved,
      isApplied: job.isApplied,
    );
  }

  Job toEntity() {
    return Job(
      id: id,
      title: title,
      company: company,
      companyLogoUrl: companyLogoUrl,
      location: location,
      workLocation: _stringToWorkLocation(workLocation),
      jobType: _stringToJobType(jobType),
      description: description,
      responsibilities: responsibilities,
      requirements: requirements,
      benefits: benefits,
      salaryRange: salaryRange,
      experienceLevel: experienceLevel,
      skills: skills,
      applyUrl: applyUrl,
      postedDate: postedDate,
      deadline: deadline,
      isSaved: isSaved,
      isApplied: isApplied,
    );
  }

  static String _workLocationToString(WorkLocation workLocation) {
    switch (workLocation) {
      case WorkLocation.onsite:
        return 'onsite';
      case WorkLocation.remote:
        return 'remote';
      case WorkLocation.hybrid:
        return 'hybrid';
    }
  }

  static WorkLocation _stringToWorkLocation(String workLocation) {
    switch (workLocation.toLowerCase()) {
      case 'remote':
        return WorkLocation.remote;
      case 'hybrid':
        return WorkLocation.hybrid;
      default:
        return WorkLocation.onsite;
    }
  }

  static String _jobTypeToString(JobType jobType) {
    switch (jobType) {
      case JobType.fullTime:
        return 'fullTime';
      case JobType.partTime:
        return 'partTime';
      case JobType.contract:
        return 'contract';
      case JobType.internship:
        return 'internship';
      case JobType.temporary:
        return 'temporary';
    }
  }

  static JobType _stringToJobType(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'parttime':
      case 'part-time':
      case 'partTime':
        return JobType.partTime;
      case 'contract':
        return JobType.contract;
      case 'internship':
        return JobType.internship;
      case 'temporary':
        return JobType.temporary;
      default:
        return JobType.fullTime;
    }
  }
}
