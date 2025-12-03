class SessionManager {
  static Map<String, dynamic>? currentUser;

  static bool get isLogged => currentUser != null;

  static void login(Map<String, dynamic> userData) {
    currentUser = userData;
  }

  static void logout() {
    currentUser = null;
  }
}
