import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService with ChangeNotifier {
  static const String _tokenKey = 'user_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _loginStatusKey = 'login_status';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> setEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
    notifyListeners();
  }

  Future<String> getEmail() async {
    return await _storage.read(key: _emailKey) ?? '';
  }

  Future<void> setName(String name) async {
    await _storage.write(key: _nameKey, value: name);
    notifyListeners();
  }

  Future<String> getName() async {
    return await _storage.read(key: _nameKey) ?? '';
  }

  Future<void> setUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
    notifyListeners();
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> setLoginStatus(bool status) async {
    await _storage.write(key: _loginStatusKey, value: status.toString());
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final status = await _storage.read(key: _loginStatusKey);
    return status == 'true';
  }

  Future<void> saveUserSession({
    required String token,
    required String email,
    required String name,
    required String userId,
  }) async {
    await setToken(token);
    await setEmail(email);
    await setName(name);
    await setUserId(userId);
    await setLoginStatus(true);
    notifyListeners();
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _loginStatusKey);
    notifyListeners();
  }

  Future<bool> hasValidSession() async {
    final token = await getAuthToken();
    final loggedIn = await isLoggedIn();
    final userId = await getUserId();
    return token != null && token.isNotEmpty && loggedIn && userId != null;
  }
}