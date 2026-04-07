/// Base Remote Data Source interface
abstract class RemoteDataSource {
  // Common remote data source methods
}

/// Base Local Data Source interface
abstract class LocalDataSource {
  // Common local data source methods
}

/// Cache Data Source for storing data locally
abstract class CacheDataSource {
  // Common cache operations
  Future<void> clearCache();
  Future<void> clearCacheByKey(String key);
}