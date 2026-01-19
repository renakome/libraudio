import 'dart:io';

/// Platform-specific optimizations for Libraudio
/// This class handles platform-dependent configurations to improve performance
/// while maintaining cross-platform compatibility
class PlatformOptimizer {
  // Lazy initialization of platform flags
  static bool? _isAndroidRuntime;
  static bool? _isIOSRuntime;
  static bool? _isDesktopRuntime;

  /// Check if running on Android with runtime detection
  static bool get isAndroid {
    _isAndroidRuntime ??= Platform.isAndroid;
    return _isAndroidRuntime!;
  }

  /// Check if running on iOS with runtime detection
  static bool get isIOS {
    _isIOSRuntime ??= Platform.isIOS;
    return _isIOSRuntime!;
  }

  /// Check if running on desktop platforms (Windows, Linux, macOS)
  static bool get isDesktop {
    _isDesktopRuntime ??= Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return _isDesktopRuntime!;
  }

  /// Check if running on mobile platforms (Android, iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Get optimal audio configuration based on platform
  static AudioConfig getOptimalAudioConfig() {
    if (isAndroid) {
      return const AudioConfig(
        bufferSize: 64 * 1024, // 64KB for Android
        preloadBufferSize: 128 * 1024, // 128KB preload
        enableGaplessPlayback: true,
        usePlatformOptimizations: true,
      );
    } else if (isIOS) {
      return const AudioConfig(
        bufferSize: 32 * 1024, // 32KB for iOS
        preloadBufferSize: 64 * 1024, // 64KB preload
        enableGaplessPlayback: true,
        usePlatformOptimizations: true,
      );
    } else {
      // Desktop platforms
      return const AudioConfig(
        bufferSize: 128 * 1024, // 128KB for desktop
        preloadBufferSize: 256 * 1024, // 256KB preload
        enableGaplessPlayback: false,
        usePlatformOptimizations: false,
      );
    }
  }

  /// Get optimal UI configuration based on platform
  static UIConfig getOptimalUIConfig() {
    if (isAndroid) {
      return const UIConfig(
        enableEdgeToEdge: true,
        useSystemNavigation: true,
        optimizeForTouch: true,
        enableHardwareAcceleration: true,
      );
    } else if (isIOS) {
      return const UIConfig(
        enableEdgeToEdge: false,
        useSystemNavigation: false,
        optimizeForTouch: true,
        enableHardwareAcceleration: true,
      );
    } else {
      return const UIConfig(
        enableEdgeToEdge: false,
        useSystemNavigation: false,
        optimizeForTouch: false,
        enableHardwareAcceleration: true,
      );
    }
  }

  /// Get optimal cache configuration based on platform
  static CacheConfig getOptimalCacheConfig() {
    if (isMobile) {
      return const CacheConfig(
        maxMemoryCacheSize: 50 * 1024 * 1024, // 50MB for mobile
        maxDiskCacheSize: 100 * 1024 * 1024, // 100MB for mobile
        enableMemoryCache: true,
        enableDiskCache: true,
        compressionEnabled: true,
      );
    } else {
      return const CacheConfig(
        maxMemoryCacheSize: 200 * 1024 * 1024, // 200MB for desktop
        maxDiskCacheSize: 500 * 1024 * 1024, // 500MB for desktop
        enableMemoryCache: true,
        enableDiskCache: true,
        compressionEnabled: false,
      );
    }
  }

  /// Get optimal network configuration based on platform
  static NetworkConfig getOptimalNetworkConfig() {
    if (isAndroid) {
      return const NetworkConfig(
        timeout: Duration(seconds: 15),
        maxRetries: 3,
        enableConnectionPooling: true,
        useCronetIfAvailable: true,
      );
    } else if (isIOS) {
      return const NetworkConfig(
        timeout: Duration(seconds: 15),
        maxRetries: 3,
        enableConnectionPooling: true,
        useCronetIfAvailable: false,
      );
    } else {
      return const NetworkConfig(
        timeout: Duration(seconds: 30),
        maxRetries: 5,
        enableConnectionPooling: true,
        useCronetIfAvailable: false,
      );
    }
  }

  /// Initialize platform-specific optimizations
  static Future<void> initialize() async {
    if (isAndroid) {
      // Android-specific initialization
      await _initializeAndroidOptimizations();
    } else if (isIOS) {
      // iOS-specific initialization
      await _initializeIOSOptimizations();
    } else {
      // Desktop-specific initialization
      await _initializeDesktopOptimizations();
    }
  }

  static Future<void> _initializeAndroidOptimizations() async {
    // Android-specific performance optimizations
    // These are already handled in main.dart but can be centralized here
  }

  static Future<void> _initializeIOSOptimizations() async {
    // iOS-specific performance optimizations
  }

  static Future<void> _initializeDesktopOptimizations() async {
    // Desktop-specific performance optimizations
  }

  /// Get optimal list view configuration for better scrolling performance
  static ListViewConfig getOptimalListViewConfig() {
    if (isMobile) {
      return const ListViewConfig(
        cacheExtent: 500.0, // Cache 500px above and below viewport
        enableShrinkWrap: false,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
      );
    } else {
      return const ListViewConfig(
        cacheExtent: 1000.0, // Larger cache for desktop
        enableShrinkWrap: false,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: false,
        addSemanticIndexes: false,
      );
    }
  }
}

/// Configuration classes for different optimizations
class AudioConfig {
  final int bufferSize;
  final int preloadBufferSize;
  final bool enableGaplessPlayback;
  final bool usePlatformOptimizations;

  const AudioConfig({
    required this.bufferSize,
    required this.preloadBufferSize,
    required this.enableGaplessPlayback,
    required this.usePlatformOptimizations,
  });
}

class UIConfig {
  final bool enableEdgeToEdge;
  final bool useSystemNavigation;
  final bool optimizeForTouch;
  final bool enableHardwareAcceleration;

  const UIConfig({
    required this.enableEdgeToEdge,
    required this.useSystemNavigation,
    required this.optimizeForTouch,
    required this.enableHardwareAcceleration,
  });
}

class CacheConfig {
  final int maxMemoryCacheSize;
  final int maxDiskCacheSize;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final bool compressionEnabled;

  const CacheConfig({
    required this.maxMemoryCacheSize,
    required this.maxDiskCacheSize,
    required this.enableMemoryCache,
    required this.enableDiskCache,
    required this.compressionEnabled,
  });
}

class NetworkConfig {
  final Duration timeout;
  final int maxRetries;
  final bool enableConnectionPooling;
  final bool useCronetIfAvailable;

  const NetworkConfig({
    required this.timeout,
    required this.maxRetries,
    required this.enableConnectionPooling,
    required this.useCronetIfAvailable,
  });
}

class ListViewConfig {
  final double cacheExtent;
  final bool enableShrinkWrap;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  const ListViewConfig({
    required this.cacheExtent,
    required this.enableShrinkWrap,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.addSemanticIndexes,
  });
}
