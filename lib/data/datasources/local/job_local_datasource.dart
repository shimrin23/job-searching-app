import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/job_model.dart';

abstract class JobLocalDataSource {
  Future<void> cacheJobs(List<JobModel> jobs);
  Future<List<JobModel>> getCachedJobs();
  Future<void> cacheJob(JobModel job);
  Future<JobModel?> getCachedJob(String jobId);
  Future<void> clearCache();
  Future<void> saveJob(String jobId);
  Future<void> unsaveJob(String jobId);
  Future<List<String>> getSavedJobIds();
  Future<void> markAsApplied(String jobId);
  Future<List<String>> getAppliedJobIds();
}

class JobLocalDataSourceImpl implements JobLocalDataSource {
  Box<JobModel>? _jobsBox;
  Box<String>? _savedJobsBox;
  Box<String>? _appliedJobsBox;

  Future<Box<JobModel>> get jobsBox async {
    if (_jobsBox == null || !_jobsBox!.isOpen) {
      _jobsBox = await Hive.openBox<JobModel>(AppConstants.jobsBox);
    }
    return _jobsBox!;
  }

  Future<Box<String>> get savedJobsBox async {
    if (_savedJobsBox == null || !_savedJobsBox!.isOpen) {
      _savedJobsBox = await Hive.openBox<String>(AppConstants.savedJobsBox);
    }
    return _savedJobsBox!;
  }

  Future<Box<String>> get appliedJobsBox async {
    if (_appliedJobsBox == null || !_appliedJobsBox!.isOpen) {
      _appliedJobsBox = await Hive.openBox<String>('applied_jobs_box');
    }
    return _appliedJobsBox!;
  }

  @override
  Future<void> cacheJobs(List<JobModel> jobs) async {
    try {
      final box = await jobsBox;
      final Map<String, JobModel> jobsMap = {for (var job in jobs) job.id: job};
      await box.putAll(jobsMap);
    } catch (e) {
      throw CacheException('Failed to cache jobs: $e');
    }
  }

  @override
  Future<List<JobModel>> getCachedJobs() async {
    try {
      final box = await jobsBox;
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get cached jobs: $e');
    }
  }

  @override
  Future<void> cacheJob(JobModel job) async {
    try {
      final box = await jobsBox;
      await box.put(job.id, job);
    } catch (e) {
      throw CacheException('Failed to cache job: $e');
    }
  }

  @override
  Future<JobModel?> getCachedJob(String jobId) async {
    try {
      final box = await jobsBox;
      return box.get(jobId);
    } catch (e) {
      throw CacheException('Failed to get cached job: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await jobsBox;
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> saveJob(String jobId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw CacheException('User not authenticated');
      }

      // Save to Firestore with user ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_jobs')
          .doc(jobId)
          .set({'jobId': jobId, 'savedAt': FieldValue.serverTimestamp()});

      // Also save locally for offline access
      final box = await savedJobsBox;
      await box.put('$userId:$jobId', jobId);
    } catch (e) {
      throw CacheException('Failed to save job: $e');
    }
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw CacheException('User not authenticated');
      }

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_jobs')
          .doc(jobId)
          .delete();

      // Also delete locally
      final box = await savedJobsBox;
      await box.delete('$userId:$jobId');
    } catch (e) {
      throw CacheException('Failed to unsave job: $e');
    }
  }

  @override
  Future<List<String>> getSavedJobIds() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      // Fetch from Firestore for current user
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_jobs')
          .get();

      final jobIds = snapshot.docs.map((doc) => doc.id).toList();

      // Update local cache
      final box = await savedJobsBox;
      await box.clear();
      for (var jobId in jobIds) {
        await box.put('$userId:$jobId', jobId);
      }

      return jobIds;
    } catch (e) {
      throw CacheException('Failed to get saved jobs: $e');
    }
  }

  @override
  Future<void> markAsApplied(String jobId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw CacheException('User not authenticated');
      }

      // Save to Firestore with user ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('applied_jobs')
          .doc(jobId)
          .set({'jobId': jobId, 'appliedAt': FieldValue.serverTimestamp()});

      // Also save locally
      final box = await appliedJobsBox;
      await box.put('$userId:$jobId', jobId);
    } catch (e) {
      throw CacheException('Failed to mark job as applied: $e');
    }
  }

  @override
  Future<List<String>> getAppliedJobIds() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      // Fetch from Firestore for current user
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('applied_jobs')
          .get();

      final jobIds = snapshot.docs.map((doc) => doc.id).toList();

      // Update local cache
      final box = await appliedJobsBox;
      await box.clear();
      for (var jobId in jobIds) {
        await box.put('$userId:$jobId', jobId);
      }

      return jobIds;
    } catch (e) {
      throw CacheException('Failed to get applied jobs: $e');
    }
  }
}
