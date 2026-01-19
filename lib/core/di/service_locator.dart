import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/local/job_local_datasource.dart';
import '../../data/datasources/local/user_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/job_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../services/storage_service.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/job/job_bloc.dart';
import '../../logic/saved_jobs/saved_jobs_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../network/network_info.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton(() => Connectivity());

  // Dio
  getIt.registerLazySingleton(
    () => Dio()
      ..options = BaseOptions(
        baseUrl: 'https://api.example.com/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      )
      ..interceptors.addAll([
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      ]),
  );

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Services
  getIt.registerLazySingleton(() => StorageService());

  // Data Sources - Local
  getIt.registerLazySingleton<JobLocalDataSource>(
    () => JobLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(),
  );

  // Data Sources - Remote
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: getIt(), firestore: getIt()),
  );
  getIt.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(dio: getIt(), firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(storage: getIt()),
  );

  // BLoCs
  getIt.registerFactory(() => AuthBloc(authRepository: getIt()));
  getIt.registerFactory(() => JobBloc(jobRepository: getIt()));
  getIt.registerFactory(() => SavedJobsBloc(jobRepository: getIt()));
  getIt.registerFactory(
    () => ProfileBloc(authRepository: getIt(), storageRepository: getIt()),
  );
}
