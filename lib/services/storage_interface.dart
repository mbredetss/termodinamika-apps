// storage_interface.dart - Common interface for storage operations

abstract class StorageServiceInterface {
  Future<void> setItem(String key, String value);
  Future<String?> getItem(String key);
  Future<void> removeItem(String key);
  Future<void> clear();
}