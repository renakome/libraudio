import 'package:flutter/material.dart';
import 'package:musily/features/settings/domain/enums/accent_color_preference.dart';
import 'package:musily/features/settings/domain/enums/close_preference.dart';

class SettingsMethods {
  final Future<void> Function(
    String? locale,
  ) changeLanguage;
  final void Function(ThemeMode? mode) changeTheme;
  final Future<void> Function() loadLanguage;
  final Future<void> Function() loadThemeMode;
  final void Function() setBrightness;
  final void Function() loadClosePreference;
  final void Function(ClosePreference preference) setClosePreference;
  final void Function(
    AccentColorPreference preference,
  ) setAccentColorPreference;
  final void Function() loadAccentColorPreference;
  final Future<void> Function({bool forceRefresh}) loadSupporters;
  final Future<void> Function(bool value) setShowSupporters;
  final Future<void> Function() loadShowSupporters;
  final void Function(String imageUrl) updatePlayerAccentColor;
  final Future<void> Function() uninstallApp;

  // Advanced Settings Load Methods
  final Future<void> Function() loadAdvancedPlayerSettings;
  final Future<void> Function() loadAdvancedAppearanceSettings;
  final Future<void> Function() loadContentSettings;
  final Future<void> Function() loadPrivacySettings;
  final Future<void> Function() loadStorageSettings;

  // Advanced Player/Audio Settings Methods
  final void Function(AudioQuality quality) setAudioQuality;
  final void Function(bool value) setSkipSilence;
  final void Function(bool value) setAudioNormalization;
  final void Function(bool value) setPersistentQueue;
  final void Function(bool value) setAutoLoadMore;
  final void Function(bool value) setSimilarContent;
  final void Function(bool value) setAutoSkipNextOnError;
  final void Function(bool value) setStopMusicOnTaskClear;

  // Advanced Appearance Settings Methods
  final void Function(bool value) setDynamicTheme;
  final void Function(bool value) setPureBlack;
  final void Function(PlayerBackgroundStyle style) setPlayerBackgroundStyle;
  final void Function(PlayerButtonsStyle style) setPlayerButtonsStyle;
  final void Function(SliderStyle style) setSliderStyle;
  final void Function(GridItemSize size) setGridItemSize;
  final void Function(bool value) setSwipeThumbnail;
  final void Function(bool value) setAnimateLyrics;
  final void Function(bool value) setRotateBackground;

  // Content Settings Methods
  final void Function(String? language) setContentLanguage;
  final void Function(String? country) setContentCountry;
  final void Function(bool value) setHideExplicit;
  final void Function(bool value) setProxyEnabled;
  final void Function(String? url) setProxyUrl;
  final void Function(String? type) setProxyType;
  final void Function(bool value) setYtmSync;

  // Privacy Settings Methods
  final void Function(bool value) setPauseListenHistory;
  final void Function(bool value) setPauseSearchHistory;
  final void Function(bool value) setDisableScreenshot;

  // Storage Settings Methods
  final void Function(int size) setMaxImageCacheSize;
  final void Function(int size) setMaxSongCacheSize;

  SettingsMethods({
    required this.changeLanguage,
    required this.changeTheme,
    required this.loadLanguage,
    required this.loadThemeMode,
    required this.setBrightness,
    required this.loadClosePreference,
    required this.setClosePreference,
    required this.setAccentColorPreference,
    required this.loadAccentColorPreference,
    required this.loadSupporters,
    required this.setShowSupporters,
    required this.loadShowSupporters,
    required this.updatePlayerAccentColor,
    required this.uninstallApp,
    // Advanced Settings Load Methods
    required this.loadAdvancedPlayerSettings,
    required this.loadAdvancedAppearanceSettings,
    required this.loadContentSettings,
    required this.loadPrivacySettings,
    required this.loadStorageSettings,
    // Advanced Player/Audio Settings Methods
    required this.setAudioQuality,
    required this.setSkipSilence,
    required this.setAudioNormalization,
    required this.setPersistentQueue,
    required this.setAutoLoadMore,
    required this.setSimilarContent,
    required this.setAutoSkipNextOnError,
    required this.setStopMusicOnTaskClear,
    // Advanced Appearance Settings Methods
    required this.setDynamicTheme,
    required this.setPureBlack,
    required this.setPlayerBackgroundStyle,
    required this.setPlayerButtonsStyle,
    required this.setSliderStyle,
    required this.setGridItemSize,
    required this.setSwipeThumbnail,
    required this.setAnimateLyrics,
    required this.setRotateBackground,
    // Content Settings Methods
    required this.setContentLanguage,
    required this.setContentCountry,
    required this.setHideExplicit,
    required this.setProxyEnabled,
    required this.setProxyUrl,
    required this.setProxyType,
    required this.setYtmSync,
    // Privacy Settings Methods
    required this.setPauseListenHistory,
    required this.setPauseSearchHistory,
    required this.setDisableScreenshot,
    // Storage Settings Methods
    required this.setMaxImageCacheSize,
    required this.setMaxSongCacheSize,
  });
}
