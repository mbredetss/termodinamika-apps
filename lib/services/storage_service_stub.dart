// storage_service_stub.dart - Mobile/Non-web implementation

import 'package:shared_preferences/shared_preferences.dart';
import 'storage_interface.dart';

/// Mobile implementation using SharedPreferences
class MobileStorageService implements StorageServiceInterface {
  @override
  Future<void> setItem(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

StorageServiceInterface getStorageService() {
  return MobileStorageService();
}