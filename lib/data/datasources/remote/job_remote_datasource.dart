import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/job_filters.dart';
import '../../../services/muse_api_service.dart';
import '../../models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs({int page = 1, JobFilters? filters});
  Future<JobModel> getJobById(String jobId);
  Future<List<JobModel>> searchJobs(String query);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;
  final FirebaseFirestore firestore;
  final MuseApiService museApiService;

  JobRemoteDataSourceImpl({
    required this.dio,
    required this.firestore,
    MuseApiService? museApiService,
  }) : museApiService = museApiService ?? MuseApiService();

  @override
  Future<List<JobModel>> getJobs({int page = 1, JobFilters? filters}) async {
    List<JobModel> allJobs = [];

    // 1. Fetch Firestore jobs (manually added by admin)
    try {
      Query query = firestore.collection(AppConstants.jobsCollection);

      if (filters?.searchQuery != null && filters!.searchQuery!.isNotEmpty) {
        query = query.where(
          'title',
          isGreaterThanOrEqualTo: filters.searchQuery,
          isLessThan: '${filters.searchQuery}z',
        );
      }

      query = query.orderBy('postedDate', descending: true).limit(50);

      final snapshot = await query.get();
      final firestoreJobs = snapshot.docs
          .map(
            (doc) => JobModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();

      allJobs.addAll(firestoreJobs);
    } catch (e) {
      print('Firestore error: $e');
    }

    // 2. Fetch The Muse API jobs
    try {
      final response = await museApiService.getJobs(
        page: page - 1,
        pageSize: 20,
        location: filters?.location,
      );

      final apiJobs = (response['results'] as List<dynamic>)
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .toList();

      allJobs.addAll(apiJobs);
    } catch (e) {
      print('The Muse API error: $e');
    }

    // 3. Remove duplicates (by ID) and return
    final uniqueJobs = <String, JobModel>{};
    for (var job in allJobs) {
      uniqueJobs[job.id] = job;
    }

    return uniqueJobs.values.toList();
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    try {
      // Try The Muse API first
      final response = await museApiService.getJobById(jobId);
      return JobModel.fromJson(response);
    } catch (e) {
      print('The Muse API error: $e');
      // Fallback to Firestore
      try {
        final doc = await firestore
            .collection(AppConstants.jobsCollection)
            .doc(jobId)
            .get();

        if (!doc.exists) {
          throw ServerException('Job not found', 404);
        }

        return JobModel.fromJson({...doc.data()!, 'id': doc.id});
      } catch (e2) {
        throw ServerException('Failed to fetch job: $e2');
      }
    }
  }

  @override
  Future<List<JobModel>> searchJobs(String query) async {
    try {
      // The Muse API doesn't have full-text search, so we:
      // 1. Try searching by company name
      // 2. Fetch general jobs and filter locally by title/company

      final lowerQuery = query.toLowerCase();

      // Try company search first
      try {
        final companyResponse = await museApiService.searchJobs(query);
        final companyJobs = (companyResponse['results'] as List<dynamic>)
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();

        if (companyJobs.isNotEmpty) {
          return companyJobs;
        }
      } catch (e) {
        print('Company search failed: $e');
      }

      // Fetch general jobs and filter by query
      final response = await museApiService.getJobs(page: 0, pageSize: 20);
      final allJobs = (response['results'] as List<dynamic>)
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter jobs by title or company name
      final filteredJobs = allJobs.where((job) {
        return job.title.toLowerCase().contains(lowerQuery) ||
            job.company.toLowerCase().contains(lowerQuery) ||
            job.location.toLowerCase().contains(lowerQuery);
      }).toList();

      return filteredJobs;
    } catch (e) {
      throw ServerException('Failed to search jobs: $e');
    }
  }
}
