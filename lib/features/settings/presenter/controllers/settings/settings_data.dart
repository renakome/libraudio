import 'package:flutter/material.dart';

import 'package:musily/core/domain/presenter/app_controller.dart';
import 'package:musily/features/settings/domain/entities/supporter_entity.dart';
import 'package:musily/features/settings/domain/enums/accent_color_preference.dart';
import 'package:musily/features/settings/domain/enums/close_preference.dart';

class SettingsData implements BaseControllerData {
  Locale? locale;
  ThemeMode? themeMode;
  BuildContext? context;
  ClosePreference closePreference;
  AccentColorPreference accentColorPreference;
  List<SupporterEntity> supporters;
  bool loadingSupporters;
  Color? playerAccentColor;
  bool showSupporters;

  // Advanced Player/Audio Settings
  AudioQuality audioQuality;
  bool skipSilence;
  bool audioNormalization;
  bool persistentQueue;
  bool autoLoadMore;
  bool similarContent;
  bool autoSkipNextOnError;
  bool stopMusicOnTaskClear;

  // Advanced Appearance Settings
  bool dynamicTheme;
  bool pureBlack;
  PlayerBackgroundStyle playerBackgroundStyle;
  PlayerButtonsStyle playerButtonsStyle;
  SliderStyle sliderStyle;
  GridItemSize gridItemSize;
  bool swipeThumbnail;
  bool animateLyrics;
  bool rotateBackground;

  // Content Settings
  String? contentLanguage;
  String? contentCountry;
  bool hideExplicit;
  bool proxyEnabled;
  String? proxyUrl;
  String? proxyType;
  bool ytmSync;

  // Privacy Settings
  bool pauseListenHistory;
  bool pauseSearchHistory;
  bool disableScreenshot;

  // Storage Settings
  int maxImageCacheSize;
  int maxSongCacheSize;

  SettingsData({
    this.locale,
    this.themeMode,
    this.context,
    this.closePreference = ClosePreference.hide,
    this.accentColorPreference = AccentColorPreference.system,
    this.supporters = const [],
    this.loadingSupporters = false,
    this.playerAccentColor,
    this.showSupporters = true,
    // Advanced Player/Audio Settings
    this.audioQuality = AudioQuality.auto,
    this.skipSilence = false,
    this.audioNormalization = true,
    this.persistentQueue = true,
    this.autoLoadMore = true,
    this.similarContent = true,
    this.autoSkipNextOnError = false,
    this.stopMusicOnTaskClear = false,
    // Advanced Appearance Settings
    this.dynamicTheme = true,
    this.pureBlack = false,
    this.playerBackgroundStyle = PlayerBackgroundStyle.default_,
    this.playerButtonsStyle = PlayerButtonsStyle.default_,
    this.sliderStyle = SliderStyle.squiggly,
    this.gridItemSize = GridItemSize.big,
    this.swipeThumbnail = true,
    this.animateLyrics = true,
    this.rotateBackground = false,
    // Content Settings
    this.contentLanguage,
    this.contentCountry,
    this.hideExplicit = false,
    this.proxyEnabled = false,
    this.proxyUrl,
    this.proxyType,
    this.ytmSync = false,
    // Privacy Settings
    this.pauseListenHistory = false,
    this.pauseSearchHistory = false,
    this.disableScreenshot = false,
    // Storage Settings
    this.maxImageCacheSize = 100, // MB
    this.maxSongCacheSize = 1000, // MB
  });

  @override
  SettingsData copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    BuildContext? context,
    ClosePreference? closePreference,
    AccentColorPreference? accentColorPreference,
    List<SupporterEntity>? supporters,
    bool? loadingSupporters,
    Color? playerAccentColor,
    bool? showSupporters,
    // Advanced Player/Audio Settings
    AudioQuality? audioQuality,
    bool? skipSilence,
    bool? audioNormalization,
    bool? persistentQueue,
    bool? autoLoadMore,
    bool? similarContent,
    bool? autoSkipNextOnError,
    bool? stopMusicOnTaskClear,
    // Advanced Appearance Settings
    bool? dynamicTheme,
    bool? pureBlack,
    PlayerBackgroundStyle? playerBackgroundStyle,
    PlayerButtonsStyle? playerButtonsStyle,
    SliderStyle? sliderStyle,
    GridItemSize? gridItemSize,
    bool? swipeThumbnail,
    bool? animateLyrics,
    bool? rotateBackground,
    // Content Settings
    String? contentLanguage,
    String? contentCountry,
    bool? hideExplicit,
    bool? proxyEnabled,
    String? proxyUrl,
    String? proxyType,
    bool? ytmSync,
    // Privacy Settings
    bool? pauseListenHistory,
    bool? pauseSearchHistory,
    bool? disableScreenshot,
    // Storage Settings
    int? maxImageCacheSize,
    int? maxSongCacheSize,
  }) {
    return SettingsData(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      context: context ?? this.context,
      closePreference: closePreference ?? this.closePreference,
      accentColorPreference:
          accentColorPreference ?? this.accentColorPreference,
      supporters: supporters ?? this.supporters,
      loadingSupporters: loadingSupporters ?? this.loadingSupporters,
      playerAccentColor: playerAccentColor ?? this.playerAccentColor,
      showSupporters: showSupporters ?? this.showSupporters,
      // Advanced Player/Audio Settings
      audioQuality: audioQuality ?? this.audioQuality,
      skipSilence: skipSilence ?? this.skipSilence,
      audioNormalization: audioNormalization ?? this.audioNormalization,
      persistentQueue: persistentQueue ?? this.persistentQueue,
      autoLoadMore: autoLoadMore ?? this.autoLoadMore,
      similarContent: similarContent ?? this.similarContent,
      autoSkipNextOnError: autoSkipNextOnError ?? this.autoSkipNextOnError,
      stopMusicOnTaskClear: stopMusicOnTaskClear ?? this.stopMusicOnTaskClear,
      // Advanced Appearance Settings
      dynamicTheme: dynamicTheme ?? this.dynamicTheme,
      pureBlack: pureBlack ?? this.pureBlack,
      playerBackgroundStyle: playerBackgroundStyle ?? this.playerBackgroundStyle,
      playerButtonsStyle: playerButtonsStyle ?? this.playerButtonsStyle,
      sliderStyle: sliderStyle ?? this.sliderStyle,
      gridItemSize: gridItemSize ?? this.gridItemSize,
      swipeThumbnail: swipeThumbnail ?? this.swipeThumbnail,
      animateLyrics: animateLyrics ?? this.animateLyrics,
      rotateBackground: rotateBackground ?? this.rotateBackground,
      // Content Settings
      contentLanguage: contentLanguage ?? this.contentLanguage,
      contentCountry: contentCountry ?? this.contentCountry,
      hideExplicit: hideExplicit ?? this.hideExplicit,
      proxyEnabled: proxyEnabled ?? this.proxyEnabled,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      proxyType: proxyType ?? this.proxyType,
      ytmSync: ytmSync ?? this.ytmSync,
      // Privacy Settings
      pauseListenHistory: pauseListenHistory ?? this.pauseListenHistory,
      pauseSearchHistory: pauseSearchHistory ?? this.pauseSearchHistory,
      disableScreenshot: disableScreenshot ?? this.disableScreenshot,
      // Storage Settings
      maxImageCacheSize: maxImageCacheSize ?? this.maxImageCacheSize,
      maxSongCacheSize: maxSongCacheSize ?? this.maxSongCacheSize,
    );
  }
}
