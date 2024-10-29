class User {
  String id;
  String name; // Ganti username dengan name

  User({required this.id, required this.name});
}

// Singleton untuk mengakses User secara global
class UserSingleton {
  static final UserSingleton _instance = UserSingleton._internal();
  User? user;

  factory UserSingleton() {
    return _instance;
  }

  UserSingleton._internal();

  void logout() {
    user = null; // Reset user ke null saat logout
  }
}
