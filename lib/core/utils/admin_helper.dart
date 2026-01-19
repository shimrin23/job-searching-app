class AdminHelper {
  // List of admin emails with full access
  static const List<String> adminEmails = ['shimrinsmart@gmail.com'];

  /// Check if the given email has admin privileges
  static bool isAdmin(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase().trim());
  }

  /// Check if current user is admin
  static bool isCurrentUserAdmin(String? userEmail) {
    return isAdmin(userEmail);
  }
}
