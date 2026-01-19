// Core Constants
class AppConstants {
  // API
  static const String baseUrl = 'https://api.example.com/v1';
  static const String jobsEndpoint = '/jobs';
  static const String authEndpoint = '/auth';

  // Pagination
  static const int pageSize = 20;
  static const int maxRetries = 3;

  // Cache
  static const String jobsBox = 'jobs_box';
  static const String userBox = 'user_box';
  static const String savedJobsBox = 'saved_jobs_box';
  static const Duration cacheValidity = Duration(hours: 1);

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';

  // Storage Paths
  static const String resumesPath = 'resumes';
  static const String profileImagesPath = 'profile_images';

  // Deep Linking
  static const String deepLinkScheme = 'jobapp';
  static const String deepLinkHost = 'jobs';

  // Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  static const String filterKey = 'job_filters';
}

// Route Names
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String jobDetails = '/job-details';
  static const String savedJobs = '/saved-jobs';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String filters = '/filters';
  static const String application = '/application';
}
