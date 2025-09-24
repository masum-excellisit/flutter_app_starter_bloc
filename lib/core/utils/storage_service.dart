import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Regular storage methods
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  static List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs?.getStringList(key) ?? defaultValue ?? [];
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // Secure storage methods
  static Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> removeSecureString(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Token management
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await setSecureString(AppConstants.accessTokenKey, accessToken);
    await setSecureString(AppConstants.refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await getSecureString(AppConstants.accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await getSecureString(AppConstants.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await removeSecureString(AppConstants.accessTokenKey);
    await removeSecureString(AppConstants.refreshTokenKey);
  }

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setSecureString(
      AppConstants.userDataKey,
      jsonEncode(userData),
    );
  }

  // Get any field directly
  static Future<String?> getUserData(String key) async {
    final data = await getSecureString(AppConstants.userDataKey);
    if (data == null) return null;
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map[key]?.toString();
  }

  // Get full map if needed
  static Future<Map<String, dynamic>?> getUserDataMap() async {
    final data = await getSecureString(AppConstants.userDataKey);
    return data != null ? jsonDecode(data) : null;
  }

  static Future<void> clearUserData() async {
    await removeSecureString(AppConstants.userDataKey);
  }

  // First time check
  static bool isFirstTime() {
    return getBool(AppConstants.isFirstTimeKey, defaultValue: true);
  }

  static Future<void> setFirstTime(bool value) async {
    await setBool(AppConstants.isFirstTimeKey, value);
  }

  // clear all data
  static Future<void> clearAllData() async {
    await clear();
    await clearSecureStorage();
    await clearUserData();
    print("All storage data cleared.");
  }
}
