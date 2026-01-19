import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/service_locator.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_event.dart';
import 'logic/auth/auth_state.dart';
import 'logic/job/job_bloc.dart';
import 'logic/saved_jobs/saved_jobs_bloc.dart';
import 'logic/profile/profile_bloc.dart';
import 'logic/theme/theme_cubit.dart';
import 'domain/entities/job.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/navigation/main_navigation_screen.dart';
import 'presentation/screens/job_details/job_details_screen.dart';
import 'data/models/user_model_adapter.dart';
import 'data/models/job_model_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(JobModelAdapter());

  // Clear old cache to prevent structure mismatch errors
  try {
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('jobs');
  } catch (e) {
    print('Cache clear: $e');
  }

  // Setup Dependency Injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<AuthBloc>()..add(AuthStateChangeRequested()),
        ),
        BlocProvider(create: (context) => getIt<JobBloc>()),
        BlocProvider(create: (context) => getIt<SavedJobsBloc>()),
        BlocProvider(create: (context) => getIt<ProfileBloc>()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Job Search App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const MainNavigationScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/job-details') {
                final job = settings.arguments;
                if (job != null) {
                  return MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: job as Job),
                  );
                }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          return const MainNavigationScreen();
        }

        if (state.status == AuthStatus.unauthenticated) {
          return const LoginScreen();
        }

        // Loading state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
