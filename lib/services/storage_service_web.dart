// storage_service_web.dart - Web implementation

import 'package:web/web.dart' as web;
import 'storage_interface.dart';

/// Web implementation using localStorage
class WebStorageService implements StorageServiceInterface {
  @override
  Future<void> setItem(String key, String value) async {
    web.window.localStorage[key] = value;
  }

  @override
  Future<String?> getItem(String key) async {
    return web.window.localStorage[key];
  }

  @override
  Future<void> removeItem(String key) async {
    web.window.localStorage.removeItem(key);
  }

  @override
  Future<void> clear() async {
    web.window.localStorage.clear();
  }
}

StorageServiceInterface getStorageService() {
  return WebStorageService();
}