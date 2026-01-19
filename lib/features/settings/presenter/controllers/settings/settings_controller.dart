import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musily/core/data/services/tray_service.dart';
import 'package:musily/core/data/services/window_service.dart';
import 'package:musily/core/domain/adapters/http_adapter.dart';
import 'package:musily/core/domain/presenter/app_controller.dart';
import 'package:musily/core/utils/smart_cache_manager.dart';
import 'package:musily/features/settings/data/privacy_service.dart';
import 'package:musily/features/settings/domain/enums/accent_color_preference.dart';
import 'package:musily/features/settings/domain/enums/close_preference.dart';
import 'package:musily/features/settings/domain/entities/supporter_entity.dart';
import 'package:musily/features/settings/presenter/controllers/settings/settings_data.dart';
import 'package:musily/features/settings/presenter/controllers/settings/settings_methods.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class SettingsController extends BaseController<SettingsData, SettingsMethods> {
  static const bool _supportersEnabled = false;
  static const _remoteSupportersUrl =
      'https://raw.githubusercontent.com/renakome/libraudio/refs/heads/main/assets/supporters.json';
  static const _localSupportersAssetPath = 'assets/supporters.json';

  late final HttpAdapter _httpAdapter;

  SettingsController({
    required HttpAdapter httpAdapter,
  }) {
    _httpAdapter = httpAdapter;
    methods.loadLanguage();
    methods.loadThemeMode();
    methods.loadClosePreference();
    methods.loadAccentColorPreference();
    methods.loadShowSupporters();
    if (_supportersEnabled) {
      methods.loadSupporters();
    }
    // Load advanced settings
    methods.loadAdvancedPlayerSettings();
    methods.loadAdvancedAppearanceSettings();
    methods.loadContentSettings();
    methods.loadPrivacySettings();
    methods.loadStorageSettings();
    showSyncSection = httpAdapter.baseUrl.isNotEmpty;
  }

  bool showSyncSection = false;

  @override
  SettingsData defineData() {
    return SettingsData();
  }

  @override
  SettingsMethods defineMethods() {
    return SettingsMethods(
      loadClosePreference: () async {
        final prefs = await SharedPreferences.getInstance();
        final closePreference = ClosePreference.values.byName(
          prefs.getString('settings.app.close') ?? 'hide',
        );
        WindowService.setPreventClose(closePreference);
        updateData(
          data.copyWith(
            closePreference: closePreference,
          ),
        );
        while (data.context == null) {
          await Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        }
        TrayService.initContextMenu(data.context!);
      },
      setClosePreference: (preference) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('settings.app.close', preference.name);
        await WindowService.setPreventClose(preference);
        updateData(
          data.copyWith(closePreference: preference),
        );
      },
      setBrightness: () async {
        if (!Platform.isAndroid) {
          return;
        }
        while (data.context == null) {
          await Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
        }
        if (data.context!.themeMode == ThemeMode.dark) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarIconBrightness: Brightness.light,
              statusBarColor: Colors.black.withValues(alpha: 0.002),
              systemNavigationBarColor: Colors.black,
            ),
          );
        } else {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.black.withValues(alpha: 0.002),
              systemNavigationBarColor: Colors.black,
            ),
          );
        }
      },
      loadThemeMode: () async {
        final prefs = await SharedPreferences.getInstance();
        final savedThemeMode = prefs.getString('themeMode');
        data.themeMode = ThemeMode.values.byName(
          savedThemeMode ?? 'system',
        );
        methods.setBrightness();
      },
      changeLanguage: (locale) async {
        if (locale == null) {
          return;
        }
        data.locale = Locale(locale);
        updateData(data);
        TrayService.initContextMenu(
          data.context!,
          locale: Locale(locale),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('locale', locale);
      },
      changeTheme: (mode) async {
        data.themeMode = mode;
        updateData(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'themeMode',
          mode?.name ?? 'system',
        );
        methods.setBrightness();
      },
      loadLanguage: () async {
        final prefs = await SharedPreferences.getInstance();
        final savedLocale = prefs.getString('locale');
        if (savedLocale != null) {
          data.locale = Locale(savedLocale);
          updateData(data);
        } else {
          while (data.context == null) {
            await Future.delayed(
              const Duration(
                seconds: 1,
              ),
            );
          }
          data.locale = Locale(
            data.context!.localization.localeName,
          );
          updateData(data);
          methods.changeLanguage(data.locale.toString());
        }
      },
      setAccentColorPreference: (preference) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accentColorPreference', preference.name);
        updateData(data.copyWith(accentColorPreference: preference));
      },
      setShowSupporters: (value) async {
        final enabled = _supportersEnabled && value;
        if (!enabled) {
          updateData(
            data.copyWith(
              showSupporters: false,
              supporters: const [],
              loadingSupporters: false,
            ),
          );
          return;
        }
        updateData(data.copyWith(showSupporters: true));
        if (data.supporters.isEmpty) {
          await methods.loadSupporters(forceRefresh: true);
        }
      },
      loadShowSupporters: () async {
        updateData(
          data.copyWith(
            showSupporters: _supportersEnabled,
          ),
        );
      },
      // Advanced Settings Load Methods
      loadAdvancedPlayerSettings: () async {
        final prefs = await SharedPreferences.getInstance();
        final audioQuality = AudioQuality.values.byName(
          prefs.getString('audioQuality') ?? 'auto',
        );
        final skipSilence = prefs.getBool('skipSilence') ?? false;
        final audioNormalization = prefs.getBool('audioNormalization') ?? true;
        final persistentQueue = prefs.getBool('persistentQueue') ?? true;
        final autoLoadMore = prefs.getBool('autoLoadMore') ?? true;
        final similarContent = prefs.getBool('similarContent') ?? true;
        final autoSkipNextOnError = prefs.getBool('autoSkipNextOnError') ?? false;
        final stopMusicOnTaskClear = prefs.getBool('stopMusicOnTaskClear') ?? false;

        updateData(data.copyWith(
          audioQuality: audioQuality,
          skipSilence: skipSilence,
          audioNormalization: audioNormalization,
          persistentQueue: persistentQueue,
          autoLoadMore: autoLoadMore,
          similarContent: similarContent,
          autoSkipNextOnError: autoSkipNextOnError,
          stopMusicOnTaskClear: stopMusicOnTaskClear,
        ));
      },
      loadAdvancedAppearanceSettings: () async {
        final prefs = await SharedPreferences.getInstance();
        final dynamicTheme = prefs.getBool('dynamicTheme') ?? true;
        final pureBlack = prefs.getBool('pureBlack') ?? false;
        final playerBackgroundStyle = PlayerBackgroundStyle.values.byName(
          prefs.getString('playerBackgroundStyle') ?? 'default_',
        );
        final playerButtonsStyle = PlayerButtonsStyle.values.byName(
          prefs.getString('playerButtonsStyle') ?? 'default_',
        );
        final sliderStyle = SliderStyle.values.byName(
          prefs.getString('sliderStyle') ?? 'squiggly',
        );
        final gridItemSize = GridItemSize.values.byName(
          prefs.getString('gridItemSize') ?? 'big',
        );
        final swipeThumbnail = prefs.getBool('swipeThumbnail') ?? true;
        final animateLyrics = prefs.getBool('animateLyrics') ?? true;
        final rotateBackground = prefs.getBool('rotateBackground') ?? false;

        updateData(data.copyWith(
          dynamicTheme: dynamicTheme,
          pureBlack: pureBlack,
          playerBackgroundStyle: playerBackgroundStyle,
          playerButtonsStyle: playerButtonsStyle,
          sliderStyle: sliderStyle,
          gridItemSize: gridItemSize,
          swipeThumbnail: swipeThumbnail,
          animateLyrics: animateLyrics,
          rotateBackground: rotateBackground,
        ));
      },
      loadContentSettings: () async {
        final prefs = await SharedPreferences.getInstance();
        final contentLanguage = prefs.getString('contentLanguage');
        final contentCountry = prefs.getString('contentCountry');
        final hideExplicit = prefs.getBool('hideExplicit') ?? false;
        final proxyEnabled = prefs.getBool('proxyEnabled') ?? false;
        final proxyUrl = prefs.getString('proxyUrl');
        final proxyType = prefs.getString('proxyType');
        final ytmSync = prefs.getBool('ytmSync') ?? false;

        updateData(data.copyWith(
          contentLanguage: contentLanguage,
          contentCountry: contentCountry,
          hideExplicit: hideExplicit,
          proxyEnabled: proxyEnabled,
          proxyUrl: proxyUrl,
          proxyType: proxyType,
          ytmSync: ytmSync,
        ));
      },
      loadPrivacySettings: () async {
        final prefs = await SharedPreferences.getInstance();
        final pauseListenHistory = prefs.getBool('pauseListenHistory') ?? false;
        final pauseSearchHistory = prefs.getBool('pauseSearchHistory') ?? false;
        final disableScreenshot = prefs.getBool('disableScreenshot') ?? false;

        updateData(data.copyWith(
          pauseListenHistory: pauseListenHistory,
          pauseSearchHistory: pauseSearchHistory,
          disableScreenshot: disableScreenshot,
        ));

        if (disableScreenshot && Platform.isAndroid) {
          await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        }
      },
      loadStorageSettings: () async {
        final prefs = await SharedPreferences.getInstance();
        final maxImageCacheSize = prefs.getInt('maxImageCacheSize') ?? 100;
        final maxSongCacheSize = prefs.getInt('maxSongCacheSize') ?? 1000;

        updateData(data.copyWith(
          maxImageCacheSize: maxImageCacheSize,
          maxSongCacheSize: maxSongCacheSize,
        ));

        final cacheManager = await SmartCacheManager.getInstance();
        await cacheManager.updateLimits(
          maxMemoryBytes: maxImageCacheSize * 1024 * 1024,
          maxDiskBytes: maxSongCacheSize * 1024 * 1024,
        );
      },
      loadAccentColorPreference: () async {
        final prefs = await SharedPreferences.getInstance();
        final savedAccentColorPreference =
            prefs.getString('accentColorPreference');
        data.accentColorPreference = AccentColorPreference.values.byName(
          savedAccentColorPreference ?? 'playingNow',
        );
        updateData(data);
      },
      updatePlayerAccentColor: (imageUrl) async {
        final colorScheme = await ColorScheme.fromImageProvider(
          provider: NetworkImage(imageUrl),
        );
        final primaryColor = colorScheme.primary;
        updateData(data.copyWith(playerAccentColor: primaryColor));
      },
      loadSupporters: ({bool forceRefresh = false}) async {
        if (!data.showSupporters) {
          return;
        }
        if (data.loadingSupporters) {
          return;
        }
        if (!forceRefresh && data.supporters.isNotEmpty) {
          return;
        }
        updateData(
          data.copyWith(
            loadingSupporters: true,
          ),
        );
        List<SupporterEntity> supporters = const [];
        try {
          supporters = await _fetchRemoteSupporters();
        } catch (_) {
          // Ignore errors, fallback handled below.
        }
        if (supporters.isEmpty) {
          supporters = await _loadLocalSupporters();
        }
        updateData(
          data.copyWith(
            supporters: supporters,
            loadingSupporters: false,
          ),
        );
      },
      uninstallApp: () async {
        if (!Platform.isLinux) {
          return;
        }

        final homeDir = Platform.environment['HOME'];
        if (homeDir == null) {
          throw Exception('HOME environment variable not found');
        }

        final uninstallerDir = path.join(
          homeDir,
          '.musily',
          'data',
          'flutter_assets',
          'assets',
          'uninstaller',
        );

        final tarGzPath = path.join(uninstallerDir, 'musily_installer.tar.gz');
        final extractedDir = path.join(uninstallerDir, 'musily_installer');
        final binaryPath = path.join(extractedDir, 'musily_installer');

        String executablePath;

        final tarGzFile = File(tarGzPath);
        final extractedBinary = File(binaryPath);

        if (await extractedBinary.exists()) {
          executablePath = binaryPath;
        } else if (await tarGzFile.exists()) {
          final bytes = await tarGzFile.readAsBytes();
          final archive = TarDecoder().decodeBytes(
            GZipDecoder().decodeBytes(bytes),
          );

          final extractDir = Directory(extractedDir);
          if (!await extractDir.exists()) {
            await extractDir.create(recursive: true);
          }

          String? foundBinaryPath;

          for (final file in archive) {
            if (file.isFile) {
              final filePath = path.join(extractedDir, file.name);
              final outFile = File(filePath);
              await outFile.parent.create(recursive: true);
              await outFile.writeAsBytes(file.content as List<int>);

              if (file.name == 'musily_installer') {
                foundBinaryPath = filePath;
              }
            }
          }

          if (foundBinaryPath != null) {
            await Process.run('chmod', ['+x', foundBinaryPath]);
            executablePath = foundBinaryPath;
          } else if (await extractedBinary.exists()) {
            await Process.run('chmod', ['+x', binaryPath]);
            executablePath = binaryPath;
          } else {
            throw Exception('Uninstaller binary not found after extraction');
          }
        } else {
          throw Exception('Uninstaller not found');
        }

        await Process.run(executablePath, []);
      },
      // Advanced Player/Audio Settings Methods
      setAudioQuality: (quality) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('audioQuality', quality.name);
        updateData(data.copyWith(audioQuality: quality));
      },
      setSkipSilence: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('skipSilence', value);
        updateData(data.copyWith(skipSilence: value));
      },
      setAudioNormalization: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('audioNormalization', value);
        updateData(data.copyWith(audioNormalization: value));
      },
      setPersistentQueue: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('persistentQueue', value);
        updateData(data.copyWith(persistentQueue: value));
      },
      setAutoLoadMore: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('autoLoadMore', value);
        updateData(data.copyWith(autoLoadMore: value));
      },
      setSimilarContent: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('similarContent', value);
        updateData(data.copyWith(similarContent: value));
      },
      setAutoSkipNextOnError: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('autoSkipNextOnError', value);
        updateData(data.copyWith(autoSkipNextOnError: value));
      },
      setStopMusicOnTaskClear: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('stopMusicOnTaskClear', value);
        updateData(data.copyWith(stopMusicOnTaskClear: value));
      },
      // Advanced Appearance Settings Methods
      setDynamicTheme: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dynamicTheme', value);
        updateData(data.copyWith(dynamicTheme: value));
      },
      setPureBlack: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pureBlack', value);
        updateData(data.copyWith(pureBlack: value));
      },
      setPlayerBackgroundStyle: (style) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playerBackgroundStyle', style.name);
        updateData(data.copyWith(playerBackgroundStyle: style));
      },
      setPlayerButtonsStyle: (style) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playerButtonsStyle', style.name);
        updateData(data.copyWith(playerButtonsStyle: style));
      },
      setSliderStyle: (style) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sliderStyle', style.name);
        updateData(data.copyWith(sliderStyle: style));
      },
      setGridItemSize: (size) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gridItemSize', size.name);
        updateData(data.copyWith(gridItemSize: size));
      },
      setSwipeThumbnail: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('swipeThumbnail', value);
        updateData(data.copyWith(swipeThumbnail: value));
      },
      setAnimateLyrics: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('animateLyrics', value);
        updateData(data.copyWith(animateLyrics: value));
      },
      setRotateBackground: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rotateBackground', value);
        updateData(data.copyWith(rotateBackground: value));
      },
      // Content Settings Methods
      setContentLanguage: (language) async {
        final prefs = await SharedPreferences.getInstance();
        if (language != null) {
          await prefs.setString('contentLanguage', language);
        } else {
          await prefs.remove('contentLanguage');
        }
        updateData(data.copyWith(contentLanguage: language));
      },
      setContentCountry: (country) async {
        final prefs = await SharedPreferences.getInstance();
        if (country != null) {
          await prefs.setString('contentCountry', country);
        } else {
          await prefs.remove('contentCountry');
        }
        updateData(data.copyWith(contentCountry: country));
      },
      setHideExplicit: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hideExplicit', value);
        updateData(data.copyWith(hideExplicit: value));
      },
      setProxyEnabled: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('proxyEnabled', value);
        updateData(data.copyWith(proxyEnabled: value));
      },
      setProxyUrl: (url) async {
        final prefs = await SharedPreferences.getInstance();
        if (url != null) {
          await prefs.setString('proxyUrl', url);
        } else {
          await prefs.remove('proxyUrl');
        }
        updateData(data.copyWith(proxyUrl: url));
      },
      setProxyType: (type) async {
        final prefs = await SharedPreferences.getInstance();
        if (type != null) {
          await prefs.setString('proxyType', type);
        } else {
          await prefs.remove('proxyType');
        }
        updateData(data.copyWith(proxyType: type));
      },
      setYtmSync: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('ytmSync', value);
        updateData(data.copyWith(ytmSync: value));
      },
      // Privacy Settings Methods
      setPauseListenHistory: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pauseListenHistory', value);
        updateData(data.copyWith(pauseListenHistory: value));
        if (value) {
          await PrivacyService.clearListenHistory();
        }
      },
      setPauseSearchHistory: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pauseSearchHistory', value);
        updateData(data.copyWith(pauseSearchHistory: value));
        if (value) {
          await PrivacyService.clearSearchHistory();
        }
      },
      setDisableScreenshot: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('disableScreenshot', value);
        updateData(data.copyWith(disableScreenshot: value));
        if (Platform.isAndroid) {
          if (value) {
            await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
          } else {
            await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
          }
        }
      },
      // Storage Settings Methods
      setMaxImageCacheSize: (size) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('maxImageCacheSize', size);
        updateData(data.copyWith(maxImageCacheSize: size));
        final cacheManager = await SmartCacheManager.getInstance();
        await cacheManager.updateLimits(maxMemoryBytes: size * 1024 * 1024);
      },
      setMaxSongCacheSize: (size) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('maxSongCacheSize', size);
        updateData(data.copyWith(maxSongCacheSize: size));
        final cacheManager = await SmartCacheManager.getInstance();
        await cacheManager.updateLimits(maxDiskBytes: size * 1024 * 1024);
      },
    );
  }

  Future<List<SupporterEntity>> _fetchRemoteSupporters() async {
    try {
      final response = await _httpAdapter.get(_remoteSupportersUrl);
      if (response.statusCode == 200) {
        return _sortSupporters(
          SupporterEntity.listFromDynamic(response.data),
        );
      }
    } catch (_) {
      rethrow;
    }
    return const [];
  }

  Future<List<SupporterEntity>> _loadLocalSupporters() async {
    try {
      final content = await rootBundle.loadString(_localSupportersAssetPath);
      return _sortSupporters(
        SupporterEntity.listFromDynamic(content),
      );
    } catch (_) {
      return const [];
    }
  }

  List<SupporterEntity> _sortSupporters(List<SupporterEntity> supporters) {
    final sorted = List<SupporterEntity>.from(supporters);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }
}
