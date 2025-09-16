class MainUrl {
  final String env = "production";

  String getUrl() {
    if (env == "production") {
      return 'https://dummyjson.com';
    } else {
      return 'http://localhost:4000';
    }
  }
}

class EndPoints {
  static var baseUrl = MainUrl().getUrl();
  static const userLogin = '/auth/login';
  static const register = "/users/add";
  static const profile = "/users/profile";
}
