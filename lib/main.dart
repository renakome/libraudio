import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:musily/core/data/database/database.dart';
import 'package:musily/core/data/repositories/musily_repository_impl.dart';
import 'package:musily/core/data/services/ipc_service.dart';
import 'package:musily/core/data/services/ipc_service_unix.dart';
import 'package:musily/core/data/services/ipc_service_windows.dart';
import 'package:musily/core/data/services/library_migration.dart';
import 'package:musily/core/data/services/tray_service.dart';
import 'package:musily/core/data/services/updater_service.dart';
import 'package:musily/core/data/services/window_service.dart';
import 'package:musily/features/player/data/services/musily_service.dart';
import 'package:musily/core/data/services/user_service.dart';
import 'package:musily/core/presenter/widgets/app_material.dart';
import 'package:musily/core/core_module.dart';
import 'package:musily/core/utils/platform_optimizer.dart';

final mediaStorePlugin = MediaStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize platform-specific optimizations first
  await PlatformOptimizer.initialize();

  // Desktop-specific services initialization (conditional loading)
  if (PlatformOptimizer.isDesktop) {
    late IPCService ipcService;
    if (Platform.isWindows) {
      ipcService = IPCServiceWindows();
    } else {
      ipcService = IPCServiceUnix();
    }
    final isFirstInstance = await ipcService.initializeIpcServer();
    if (!isFirstInstance) {
      exit(0);
    }
    await WindowService.init();
    await TrayService.init();
  }

  // Android-specific services initialization
  if (PlatformOptimizer.isAndroid) {
    await MediaStore.ensureInitialized();
  }

  await Database().init();
  await UpdaterService.checkForUpdates();

  final userService = UserService();
  final libraryMigrationService = LibraryMigrationService();
  final musilyRepository = MusilyRepositoryImpl();

  await libraryMigrationService.migrateLibrary();
  await musilyRepository.initialize();
  await userService.initialize();

  final uiConfig = PlatformOptimizer.getOptimalUIConfig();

  await MusilyService.init(
    config: MusilyServiceConfig(
      androidNotificationChannelId: PlatformOptimizer.isAndroid ? 'app.musily.music' : null,
      androidNotificationChannelName: 'Libraudio',
      androidNotificationIcon: PlatformOptimizer.isAndroid ? 'drawable/ic_launcher_foreground' : 'mipmap/ic_launcher',
      androidShowNotificationBadge: PlatformOptimizer.isAndroid,
      androidStopForegroundOnPause: PlatformOptimizer.isAndroid ? false : true,
      // Optimize artwork downscaling based on platform
      artDownscaleWidth: PlatformOptimizer.isMobile ? 300 : 500,
      artDownscaleHeight: PlatformOptimizer.isMobile ? 300 : 500,
      preloadArtwork: PlatformOptimizer.isMobile, // Only preload on mobile for better performance
    ),
  );

  // Apply UI optimizations based on platform
  if (uiConfig.enableEdgeToEdge && PlatformOptimizer.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black.withValues(alpha: 0.002),
        systemNavigationBarColor: Colors.black.withValues(alpha: 0.002),
      ),
    );
  }

  runApp(
    ModularApp(
      module: CoreModule(),
      child: const AppMaterial(),
    ),
  );
}
