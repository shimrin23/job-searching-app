import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';

/// Service for interacting with The Muse API
/// API Documentation: https://www.themuse.com/developers/api/v2
class MuseApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://www.themuse.com/api/public';

  MuseApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Fetch jobs from The Muse API
  ///
  /// Parameters:
  /// - [page]: Page number (default: 0)
  /// - [pageSize]: Number of results per page (max: 20)
  /// - [category]: Job category filter (e.g., "Software Engineering")
  /// - [level]: Experience level (e.g., "Entry Level", "Mid Level", "Senior")
  /// - [location]: Location filter (e.g., "New York, NY")
  /// - [company]: Company name filter
  Future<Map<String, dynamic>> getJobs({
    int page = 0,
    int pageSize = 20,
    String? category,
    String? level,
    String? location,
    String? company,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'descending': true};

      if (category != null) queryParams['category'] = category;
      if (level != null) queryParams['level'] = level;
      if (location != null) queryParams['location'] = location;
      if (company != null) queryParams['company'] = company;

      final response = await _dio.get('/jobs', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Failed to fetch jobs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch jobs: $e');
    }
  }

  /// Get a single job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await _dio.get('/jobs/$jobId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Failed to fetch job: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch job: $e');
    }
  }

  /// Search jobs by query
  Future<Map<String, dynamic>> searchJobs(String query, {int page = 0}) async {
    try {
      final response = await _dio.get(
        '/jobs',
        queryParameters: {
          'page': page,
          'descending': true,
          'company': query, // Search in company names
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Failed to search jobs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to search jobs: $e');
    }
  }

  /// Get available job categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['results'] as List).cast<Map<String, dynamic>>();
      } else {
        throw ServerException(
          'Failed to fetch categories: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch categories: $e');
    }
  }
}
