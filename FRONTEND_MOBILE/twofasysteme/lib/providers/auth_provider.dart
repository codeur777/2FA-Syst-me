import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  UserModel? _user;
  bool _loading = true;
  ThemeMode _themeMode = ThemeMode.light;

  UserModel? get user => _user;
  bool get loading => _loading;
  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => _user != null;

  Future<void> init() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      try {
        final data = await ApiClient.get('/user/profile');
        _user = UserModel.fromJson(data);
        _themeMode = _user!.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      } catch (_) {
        await _storage.deleteAll();
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  Future<void> loadProfile() async {
    final data = await ApiClient.get('/user/profile');
    _user = UserModel.fromJson(data);
    _themeMode = _user!.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    final data = await ApiClient.put('/user/profile', body);
    _user = UserModel.fromJson(data);
    notifyListeners();
  }

  Future<void> toggleTwoFactor(bool enabled) async {
    final data = await ApiClient.patch('/user/2fa?enabled=$enabled');
    _user = UserModel.fromJson(data);
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final newTheme = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    _user = _user?.copyWith(theme: newTheme);
    ApiClient.put('/user/profile', {'theme': newTheme}).catchError((_) {});
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    notifyListeners();
  }
}
