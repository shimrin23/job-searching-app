import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/job.dart';
import '../entities/job_filters.dart';

abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs({
    int page = 1,
    JobFilters? filters,
  });

  Future<Either<Failure, Job>> getJobById(String jobId);

  Future<Either<Failure, List<Job>>> searchJobs(String query);

  Future<Either<Failure, void>> saveJob(String jobId);

  Future<Either<Failure, void>> unsaveJob(String jobId);

  Future<Either<Failure, List<Job>>> getSavedJobs();

  Future<Either<Failure, void>> applyToJob(String jobId);

  Future<Either<Failure, List<Job>>> getAppliedJobs();

  Future<Either<Failure, void>> clearCache();
}
