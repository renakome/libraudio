import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:musily/core/presenter/ui/ly_properties/ly_density.dart';
import 'package:musily/core/presenter/ui/text_fields/ly_dropdown_button.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import 'package:musily/features/settings/domain/enums/accent_color_preference.dart';
import 'package:musily/features/settings/domain/enums/close_preference.dart';
import 'package:musily/features/settings/presenter/controllers/settings/settings_controller.dart';
import 'package:musily/core/presenter/ui/lists/ly_list_tile.dart';

class AppSection extends StatefulWidget {
  final SettingsController controller;
  const AppSection({
    super.key,
    required this.controller,
  });

  @override
  State<AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<AppSection> {
  @override
  void initState() {
    super.initState();
    widget.controller.data.context = context;
    widget.controller.updateData(
      widget.controller.data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.builder(builder: (context, data) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.themeData.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  LucideIcons.settings,
                  size: 18,
                  color: context.themeData.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.localization.application,
                  style: context.themeData.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Settings Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                                LyDropdownButton(
                  density: LyDensity.dense,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'pt', child: Text('Portuguese')),
                    DropdownMenuItem(value: 'ru', child: Text('Russian')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'uk', child: Text('Ukrainian')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'it', child: Text('Italian')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                    DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                    DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                    DropdownMenuItem(value: 'ko', child: Text('Korean')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'id', child: Text('Indonesian')),
                    DropdownMenuItem(value: 'tr', child: Text('Turkish')),
                    DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                    DropdownMenuItem(value: 'pl', child: Text('Polish')),
                    DropdownMenuItem(value: 'th', child: Text('Thai')),
                  ],
                  value: data.locale?.languageCode,
                  onChanged: (value) {
                    widget.controller.methods.changeLanguage(value);
                  },
                  labelText: context.localization.language,
                ),
                const SizedBox(height: 12),
                LyDropdownButton<ThemeMode>(
                  labelText: context.localization.theme,
                  value: data.themeMode ?? ThemeMode.system,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(
                        context.localization.dark,
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(
                        context.localization.light,
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(
                        context.localization.system,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.changeTheme(value);
                  },
                ),
                const SizedBox(height: 12),
                LyDropdownButton<AccentColorPreference>(
                  labelText: context.localization.accentColor,
                  value: data.accentColorPreference,
                  onChanged: (value) {
                    widget.controller.methods.setAccentColorPreference(value!);
                  },
                  items: [
                    DropdownMenuItem(
                      value: AccentColorPreference.system,
                      child: Text(context.localization.system),
                    ),
                    DropdownMenuItem(
                      value: AccentColorPreference.defaultColor,
                      child: Text(context.localization.defaultColor),
                    ),
                    DropdownMenuItem(
                      value: AccentColorPreference.playingNow,
                      child: Text(context.localization.playingNow),
                    ),
                  ],
                ),
                if (Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS) ...[
                  const SizedBox(height: 12),
                  LyDropdownButton<ClosePreference>(
                    labelText: context.localization.whenClosingTheApplication,
                    density: LyDensity.dense,
                    value: data.closePreference,
                    onChanged: (value) {
                      widget.controller.methods.setClosePreference(value!);
                    },
                    items: [
                      DropdownMenuItem(
                        value: ClosePreference.hide,
                        child: Text(context.localization.hide),
                      ),
                      DropdownMenuItem(
                        value: ClosePreference.close,
                        child: Text(context.localization.close),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Advanced Appearance Settings
                LyDropdownButton(
                  labelText: context.localization.playerBackgroundStyle,
                  value: data.playerBackgroundStyle,
                  items: const [
                    DropdownMenuItem(
                      value: PlayerBackgroundStyle.default_,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: PlayerBackgroundStyle.gradient,
                      child: Text('Gradient'),
                    ),
                    DropdownMenuItem(
                      value: PlayerBackgroundStyle.blur,
                      child: Text('Blur'),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.setPlayerBackgroundStyle(value!);
                  },
                ),
                const SizedBox(height: 12),
                LyDropdownButton(
                  labelText: context.localization.playerButtonsStyle,
                  value: data.playerButtonsStyle,
                  items: const [
                    DropdownMenuItem(
                      value: PlayerButtonsStyle.default_,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: PlayerButtonsStyle.primary,
                      child: Text('Primary'),
                    ),
                    DropdownMenuItem(
                      value: PlayerButtonsStyle.tertiary,
                      child: Text('Tertiary'),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.setPlayerButtonsStyle(value!);
                  },
                ),
                const SizedBox(height: 12),
                LyDropdownButton(
                  labelText: context.localization.sliderStyle,
                  value: data.sliderStyle,
                  items: const [
                    DropdownMenuItem(
                      value: SliderStyle.default_,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: SliderStyle.squiggly,
                      child: Text('Squiggly'),
                    ),
                    DropdownMenuItem(
                      value: SliderStyle.slim,
                      child: Text('Slim'),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.setSliderStyle(value!);
                  },
                ),
                const SizedBox(height: 12),
                LyDropdownButton(
                  labelText: context.localization.gridItemSize,
                  value: data.gridItemSize,
                  items: const [
                    DropdownMenuItem(
                      value: GridItemSize.small,
                      child: Text('Small'),
                    ),
                    DropdownMenuItem(
                      value: GridItemSize.big,
                      child: Text('Big'),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.setGridItemSize(value!);
                  },
                ),
                const SizedBox(height: 12),
                LyListTile(
                  title: Text(context.localization.dynamicTheme),
                  trailing: Switch(
                    value: data.dynamicTheme,
                    onChanged: (value) {
                      widget.controller.methods.setDynamicTheme(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.pureBlack),
                  trailing: Switch(
                    value: data.pureBlack,
                    onChanged: (value) {
                      widget.controller.methods.setPureBlack(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.rotateBackground),
                  trailing: Switch(
                    value: data.rotateBackground,
                    onChanged: (value) {
                      widget.controller.methods.setRotateBackground(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.animateLyrics),
                  trailing: Switch(
                    value: data.animateLyrics,
                    onChanged: (value) {
                      widget.controller.methods.setAnimateLyrics(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.swipeThumbnail),
                  trailing: Switch(
                    value: data.swipeThumbnail,
                    onChanged: (value) {
                      widget.controller.methods.setSwipeThumbnail(value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Player/Audio Section Header
                Container(
                  width: double.infinity,
                  height: 1,
                  color: context.themeData.colorScheme.outline.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: context.themeData.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.music,
                        size: 18,
                        color: context.themeData.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.localization.playerAndAudio,
                        style: context.themeData.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Player/Audio Settings
                LyDropdownButton(
                  labelText: context.localization.audioQuality,
                  value: data.audioQuality,
                  items: [
                    DropdownMenuItem(
                      value: AudioQuality.auto,
                      child: Text(context.localization.audioQualityAuto),
                    ),
                    DropdownMenuItem(
                      value: AudioQuality.high,
                      child: Text(context.localization.audioQualityHigh),
                    ),
                    DropdownMenuItem(
                      value: AudioQuality.low,
                      child: Text(context.localization.audioQualityLow),
                    ),
                  ],
                  onChanged: (value) {
                    widget.controller.methods.setAudioQuality(value!);
                  },
                ),
                const SizedBox(height: 12),
                LyListTile(
                  title: Text(context.localization.skipSilence),
                  trailing: Switch(
                    value: data.skipSilence,
                    onChanged: (value) {
                      widget.controller.methods.setSkipSilence(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.audioNormalization),
                  trailing: Switch(
                    value: data.audioNormalization,
                    onChanged: (value) {
                      widget.controller.methods.setAudioNormalization(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.persistentQueue),
                  subtitle: Text(context.localization.persistentQueueDesc),
                  trailing: Switch(
                    value: data.persistentQueue,
                    onChanged: (value) {
                      widget.controller.methods.setPersistentQueue(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.autoLoadMore),
                  subtitle: Text(context.localization.autoLoadMoreDesc),
                  trailing: Switch(
                    value: data.autoLoadMore,
                    onChanged: (value) {
                      widget.controller.methods.setAutoLoadMore(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.enableSimilarContent),
                  subtitle: Text(context.localization.similarContentDesc),
                  trailing: Switch(
                    value: data.similarContent,
                    onChanged: (value) {
                      widget.controller.methods.setSimilarContent(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.autoSkipNextOnError),
                  subtitle: Text(context.localization.autoSkipNextOnErrorDesc),
                  trailing: Switch(
                    value: data.autoSkipNextOnError,
                    onChanged: (value) {
                      widget.controller.methods.setAutoSkipNextOnError(value);
                    },
                  ),
                ),
                LyListTile(
                  title: Text(context.localization.stopMusicOnTaskClear),
                  trailing: Switch(
                    value: data.stopMusicOnTaskClear,
                    onChanged: (value) {
                      widget.controller.methods.setStopMusicOnTaskClear(value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      );
    });
  }
}
