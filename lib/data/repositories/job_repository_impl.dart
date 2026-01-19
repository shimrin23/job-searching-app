import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/job_filters.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/local/job_local_datasource.dart';
import '../datasources/remote/job_remote_datasource.dart';
import '../models/job_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;
  final JobLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  JobRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Job>>> getJobs({
    int page = 1,
    JobFilters? filters,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // Online: Fetch from API
        final jobModels = await remoteDataSource.getJobs(
          page: page,
          filters: filters,
        );

        // Cache the results
        if (page == 1) {
          await localDataSource.clearCache();
        }
        await localDataSource.cacheJobs(jobModels);

        // Mark saved and applied jobs
        final savedIds = await localDataSource.getSavedJobIds();
        final appliedIds = await localDataSource.getAppliedJobIds();

        final jobs = jobModels.map((model) {
          final job = model.toEntity();
          return job.copyWith(
            isSaved: savedIds.contains(job.id),
            isApplied: appliedIds.contains(job.id),
          );
        }).toList();

        return Right(jobs);
      } else {
        // Offline: Get from cache
        final cachedJobs = await localDataSource.getCachedJobs();
        if (cachedJobs.isEmpty) {
          return const Left(NetworkFailure('No cached data available'));
        }

        final savedIds = await localDataSource.getSavedJobIds();
        final appliedIds = await localDataSource.getAppliedJobIds();

        final jobs = cachedJobs.map((model) {
          final job = model.toEntity();
          return job.copyWith(
            isSaved: savedIds.contains(job.id),
            isApplied: appliedIds.contains(job.id),
          );
        }).toList();

        return Right(jobs);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> getJobById(String jobId) async {
    try {
      // Try cache first
      final cachedJob = await localDataSource.getCachedJob(jobId);

      if (await networkInfo.isConnected) {
        // Online: Fetch from API
        final jobModel = await remoteDataSource.getJobById(jobId);
        await localDataSource.cacheJob(jobModel);

        final savedIds = await localDataSource.getSavedJobIds();
        final appliedIds = await localDataSource.getAppliedJobIds();

        final job = jobModel.toEntity().copyWith(
          isSaved: savedIds.contains(jobId),
          isApplied: appliedIds.contains(jobId),
        );

        return Right(job);
      } else {
        // Offline: Use cache
        if (cachedJob == null) {
          return const Left(NotFoundFailure('Job not found in cache'));
        }

        final savedIds = await localDataSource.getSavedJobIds();
        final appliedIds = await localDataSource.getAppliedJobIds();

        final job = cachedJob.toEntity().copyWith(
          isSaved: savedIds.contains(jobId),
          isApplied: appliedIds.contains(jobId),
        );

        return Right(job);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> searchJobs(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        // Offline: Search in cache
        final cachedJobs = await localDataSource.getCachedJobs();
        final filtered = cachedJobs.where((job) {
          return job.title.toLowerCase().contains(query.toLowerCase()) ||
              job.company.toLowerCase().contains(query.toLowerCase()) ||
              job.description.toLowerCase().contains(query.toLowerCase());
        }).toList();

        final savedIds = await localDataSource.getSavedJobIds();
        final appliedIds = await localDataSource.getAppliedJobIds();

        final jobs = filtered.map((model) {
          final job = model.toEntity();
          return job.copyWith(
            isSaved: savedIds.contains(job.id),
            isApplied: appliedIds.contains(job.id),
          );
        }).toList();

        return Right(jobs);
      }

      final jobModels = await remoteDataSource.searchJobs(query);
      await localDataSource.cacheJobs(jobModels);

      final savedIds = await localDataSource.getSavedJobIds();
      final appliedIds = await localDataSource.getAppliedJobIds();

      final jobs = jobModels.map((model) {
        final job = model.toEntity();
        return job.copyWith(
          isSaved: savedIds.contains(job.id),
          isApplied: appliedIds.contains(job.id),
        );
      }).toList();

      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveJob(String jobId) async {
    try {
      await localDataSource.saveJob(jobId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveJob(String jobId) async {
    try {
      await localDataSource.unsaveJob(jobId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getSavedJobs() async {
    try {
      final savedIds = await localDataSource.getSavedJobIds();
      final appliedIds = await localDataSource.getAppliedJobIds();
      final cachedJobs = await localDataSource.getCachedJobs();

      final savedJobs = cachedJobs
          .where((job) => savedIds.contains(job.id))
          .map((model) {
            final job = model.toEntity();
            return job.copyWith(
              isSaved: true,
              isApplied: appliedIds.contains(job.id),
            );
          })
          .toList();

      return Right(savedJobs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> applyToJob(String jobId) async {
    try {
      await localDataSource.markAsApplied(jobId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Job>>> getAppliedJobs() async {
    try {
      final appliedIds = await localDataSource.getAppliedJobIds();
      final savedIds = await localDataSource.getSavedJobIds();
      final cachedJobs = await localDataSource.getCachedJobs();

      final appliedJobs = cachedJobs
          .where((job) => appliedIds.contains(job.id))
          .map((model) {
            final job = model.toEntity();
            return job.copyWith(
              isApplied: true,
              isSaved: savedIds.contains(job.id),
            );
          })
          .toList();

      return Right(appliedJobs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
