import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _tokenKey = 'token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Save user data
  static Future<void> saveUserData({
    required String token,
    required String role,
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Check if user is driver
  static Future<bool> isDriver() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'driver';
  }

  // Check if user is rider
  static Future<bool> isRider() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'rider';
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'admin';
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Get user data as map
  static Future<Map<String, String?>> getUserData() async {
    return {
      'token': await getToken(),
      'role': await getUserRole(),
      'userId': await getUserId(),
      'name': await getUserName(),
      'email': await getUserEmail(),
    };
  }
}
