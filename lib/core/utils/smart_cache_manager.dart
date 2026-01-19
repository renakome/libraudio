import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:musily/core/utils/platform_optimizer.dart';
import 'package:path_provider/path_provider.dart';

/// Smart cache manager that adapts to platform capabilities and constraints
/// Provides optimal caching strategies for different platforms while maintaining
/// cross-platform compatibility
class SmartCacheManager {
  static SmartCacheManager? _instance;
  late CacheConfig _config;
  late final Directory _cacheDir;

  // Memory cache with LRU eviction
  final LinkedHashMap<String, _CacheEntry> _memoryCache = LinkedHashMap<String, _CacheEntry>();
  int _currentMemorySize = 0;

  // File cache metadata
  final Map<String, _FileCacheEntry> _fileCacheMetadata = {};

  SmartCacheManager._() {
    _config = PlatformOptimizer.getOptimalCacheConfig();
  }

  static Future<SmartCacheManager> getInstance() async {
    if (_instance == null) {
      _instance = SmartCacheManager._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    final tempDir = await getTemporaryDirectory();
    _cacheDir = Directory('${tempDir.path}/libraudio_cache');

    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }

    // Load existing cache metadata
    await _loadCacheMetadata();

    // Clean up expired entries periodically
    Timer.periodic(const Duration(minutes: 30), (_) => _cleanupExpiredEntries());
  }

  Future<void> _loadCacheMetadata() async {
    final metadataFile = File('${_cacheDir.path}/cache_metadata.json');

    if (await metadataFile.exists()) {
      try {
        final content = await metadataFile.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;

        final entries = data['entries'] as List<dynamic>? ?? [];
        for (final entry in entries) {
          final cacheEntry = _FileCacheEntry.fromJson(entry);
          _fileCacheMetadata[cacheEntry.key] = cacheEntry;
        }
      } catch (e) {
        // If metadata is corrupted, start fresh
        await metadataFile.delete();
      }
    }
  }

  Future<void> _saveCacheMetadata() async {
    final metadataFile = File('${_cacheDir.path}/cache_metadata.json');
    final data = {
      'entries': _fileCacheMetadata.values.map((e) => e.toJson()).toList(),
    };

    await metadataFile.writeAsString(json.encode(data));
  }

  /// Get data from cache (memory first, then disk)
  Future<Uint8List?> get(String key) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      // Move to end (most recently used)
      _memoryCache.remove(key);
      _memoryCache[key] = memoryEntry;
      return memoryEntry.data;
    }

    // Check disk cache
    final fileEntry = _fileCacheMetadata[key];
    if (fileEntry != null && !fileEntry.isExpired) {
      final file = File('${_cacheDir.path}/${fileEntry.fileName}');
      if (await file.exists()) {
        try {
          final data = await file.readAsBytes();

          // Add to memory cache if enabled
          if (_config.enableMemoryCache) {
            await _addToMemoryCache(key, data, fileEntry.expiryTime);
          }

          return data;
        } catch (e) {
          // Remove corrupted entry
          _fileCacheMetadata.remove(key);
        }
      } else {
        // File doesn't exist, remove metadata
        _fileCacheMetadata.remove(key);
      }
    }

    return null;
  }

  /// Put data in cache with platform-optimized strategy
  Future<void> put(String key, Uint8List data, {Duration? ttl}) async {
    final expiryTime = DateTime.now().add(ttl ?? const Duration(hours: 24));

    // Add to memory cache if enabled
    if (_config.enableMemoryCache) {
      await _addToMemoryCache(key, data, expiryTime);
    }

    // Add to disk cache if enabled
    if (_config.enableDiskCache) {
      await _addToDiskCache(key, data, expiryTime);
    }
  }

  Future<void> _addToMemoryCache(String key, Uint8List data, DateTime expiryTime) async {
    final entry = _CacheEntry(data, expiryTime);

    // Remove existing entry if present
    _memoryCache.remove(key);

    // Check if we need to evict entries
    final entrySize = data.length;
    while (_currentMemorySize + entrySize > _config.maxMemoryCacheSize && _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.keys.first;
      final oldestEntry = _memoryCache.remove(oldestKey);
      _currentMemorySize -= oldestEntry!.data.length;
    }

    // Add new entry
    _memoryCache[key] = entry;
    _currentMemorySize += entrySize;
  }

  Future<void> _enforceMemoryCacheSize() async {
    while (_currentMemorySize > _config.maxMemoryCacheSize && _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.keys.first;
      final oldestEntry = _memoryCache.remove(oldestKey);
      _currentMemorySize -= oldestEntry!.data.length;
    }
  }

  Future<void> _addToDiskCache(String key, Uint8List data, DateTime expiryTime) async {
    final fileName = _generateFileName(key);
    final file = File('${_cacheDir.path}/$fileName');

    // Compress data if enabled and beneficial
    Uint8List dataToWrite = data;
    if (_config.compressionEnabled && data.length > 1024) {
      // Simple compression check - in real implementation you'd use proper compression
      dataToWrite = data; // Placeholder for compression logic
    }

    await file.writeAsBytes(dataToWrite);

    final entry = _FileCacheEntry(
      key: key,
      fileName: fileName,
      size: dataToWrite.length,
      expiryTime: expiryTime,
    );

    _fileCacheMetadata[key] = entry;
    await _saveCacheMetadata();

    // Clean up if disk cache is too large
    await _enforceDiskCacheSize();
  }

  Future<void> _enforceDiskCacheSize() async {
    int totalSize = 0;
    final entries = _fileCacheMetadata.values.toList()
      ..sort((a, b) => a.lastAccess.compareTo(b.lastAccess));

    for (final entry in entries) {
      totalSize += entry.size;
    }

    // Remove oldest entries if over limit
    while (totalSize > _config.maxDiskCacheSize && entries.isNotEmpty) {
      final entry = entries.removeAt(0);
      final file = File('${_cacheDir.path}/${entry.fileName}');
      if (await file.exists()) {
        await file.delete();
      }
      _fileCacheMetadata.remove(entry.key);
      totalSize -= entry.size;
    }

    if (_fileCacheMetadata.length != entries.length) {
      await _saveCacheMetadata();
    }
  }

  Future<void> updateLimits({int? maxMemoryBytes, int? maxDiskBytes}) async {
    _config = CacheConfig(
      maxMemoryCacheSize: maxMemoryBytes ?? _config.maxMemoryCacheSize,
      maxDiskCacheSize: maxDiskBytes ?? _config.maxDiskCacheSize,
      enableMemoryCache: _config.enableMemoryCache,
      enableDiskCache: _config.enableDiskCache,
      compressionEnabled: _config.compressionEnabled,
    );

    await _enforceMemoryCacheSize();
    await _enforceDiskCacheSize();
  }

  Future<void> _cleanupExpiredEntries() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    // Check memory cache
    _memoryCache.removeWhere((key, entry) {
      if (entry.isExpired) {
        _currentMemorySize -= entry.data.length;
        return true;
      }
      return false;
    });

    // Check disk cache
    _fileCacheMetadata.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
        final file = File('${_cacheDir.path}/${entry.fileName}');
        unawaited(file.delete());
      } else {
        // Update last access time for active entries
        entry.lastAccess = now;
      }
    });

    expiredKeys.forEach(_fileCacheMetadata.remove);
    if (expiredKeys.isNotEmpty) {
      await _saveCacheMetadata();
    }
  }

  String _generateFileName(String key) {
    final hash = sha256.convert(utf8.encode(key)).toString();
    return hash.substring(0, 16); // First 16 chars of hash
  }

  /// Clear all cache data
  Future<void> clear() async {
    _memoryCache.clear();
    _currentMemorySize = 0;

    for (final entry in _fileCacheMetadata.values) {
      final file = File('${_cacheDir.path}/${entry.fileName}');
      try {
        await file.delete();
      } catch (_) {
        // Ignore deletion errors while clearing cache
      }
    }

    _fileCacheMetadata.clear();
    await _saveCacheMetadata();
  }

  /// Get cache statistics
  CacheStats getStats() {
    return CacheStats(
      memoryEntries: _memoryCache.length,
      memorySize: _currentMemorySize,
      diskEntries: _fileCacheMetadata.length,
      diskSize: _fileCacheMetadata.values.fold(0, (sum, entry) => sum + entry.size),
      maxMemorySize: _config.maxMemoryCacheSize,
      maxDiskSize: _config.maxDiskCacheSize,
    );
  }
}

/// Memory cache entry
class _CacheEntry {
  final Uint8List data;
  final DateTime expiryTime;

  _CacheEntry(this.data, this.expiryTime);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// Disk cache entry metadata
class _FileCacheEntry {
  final String key;
  final String fileName;
  final int size;
  final DateTime expiryTime;
  DateTime lastAccess;

  _FileCacheEntry({
    required this.key,
    required this.fileName,
    required this.size,
    required this.expiryTime,
    DateTime? lastAccess,
  }) : lastAccess = lastAccess ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'fileName': fileName,
      'size': size,
      'expiryTime': expiryTime.toIso8601String(),
      'lastAccess': lastAccess.toIso8601String(),
    };
  }

  factory _FileCacheEntry.fromJson(Map<String, dynamic> json) {
    return _FileCacheEntry(
      key: json['key'],
      fileName: json['fileName'],
      size: json['size'],
      expiryTime: DateTime.parse(json['expiryTime']),
      lastAccess: DateTime.parse(json['lastAccess'] ?? json['expiryTime']),
    );
  }
}

/// Cache statistics
class CacheStats {
  final int memoryEntries;
  final int memorySize;
  final int diskEntries;
  final int diskSize;
  final int maxMemorySize;
  final int maxDiskSize;

  CacheStats({
    required this.memoryEntries,
    required this.memorySize,
    required this.diskEntries,
    required this.diskSize,
    required this.maxMemorySize,
    required this.maxDiskSize,
  });

  double get memoryUsageRatio => memorySize / maxMemorySize;
  double get diskUsageRatio => diskSize / maxDiskSize;
}
