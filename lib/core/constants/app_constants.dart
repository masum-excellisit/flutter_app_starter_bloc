class AppConstants {
  // API
  static const String baseUrl = 'https://dummyjson.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';

  // App Info
  static const String appName = 'Flutter Starter';
  static const String appVersion = '1.0.0';

  // Feature Toggles
  static const bool enableBottomNavigation = true;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
