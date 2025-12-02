class SessionManager {
  static Map<String, dynamic>? currentUser; // Guarda los datos del usuario

  static bool get isLogged => currentUser != null;

  static void login(Map<String, dynamic> userData) {
    currentUser = userData;
  }

  static void logout() {
    currentUser = null;
  }
}
