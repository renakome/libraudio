import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:musily/core/presenter/controllers/core/core_controller.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import 'package:musily/core/presenter/ui/utils/ly_navigator.dart';
import 'package:musily/features/settings/presenter/pages/about_page.dart';
import 'package:musily/features/settings/presenter/controllers/settings/settings_controller.dart';
import 'package:musily/features/version_manager/presenter/controllers/version_manager/version_manager_controller.dart';
import 'package:musily/features/version_manager/presenter/pages/version_manager_page.dart';

class OtherSection extends StatelessWidget {
  final CoreController coreController;
  final SettingsController settingsController;

  const OtherSection({
    super.key,
    required this.coreController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return settingsController.builder(builder: (context, data) {
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
                  color: context.themeData.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.ellipsis,
                size: 18,
                color: context.themeData.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                context.localization.others,
                style: context.themeData.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Licenses Tile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showLicensePage(
                  applicationName: 'Libraudio',
                  useRootNavigator: true,
                  applicationIcon: SvgPicture.asset(
                    'assets/icons/libraudio.svg',
                    width: 60,
                  ),
                  context: context.display.isDesktop
                      ? coreController.coreContext!
                      : context,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.themeData.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.themeData.colorScheme.outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.themeData.colorScheme.secondary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.scale,
                        size: 22,
                        color: context.themeData.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.localization.licenses,
                        style:
                            context.themeData.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: context.themeData.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Version Manager Tile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final versionController = VersionManagerController();
                LyNavigator.push(
                  context,
                  VersionManagerPage(
                    controller: versionController,
                    coreController: coreController,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.themeData.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.themeData.colorScheme.outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.themeData.colorScheme.primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.download,
                        size: 22,
                        color: context.themeData.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.localization.versionManager,
                        style:
                            context.themeData.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: context.themeData.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // About Tile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                LyNavigator.push(
                  context,
                  AboutPage(
                    controller: settingsController,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: context.themeData.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.themeData.colorScheme.outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.themeData.colorScheme.tertiary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: 22,
                        color: context.themeData.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.localization.aboutSupporters,
                        style:
                            context.themeData.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: context.themeData.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (Platform.isLinux) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  try {
                    await settingsController.methods.uninstallApp();
                  } catch (e) {
                    //
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: context.themeData.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.themeData.colorScheme.outline
                          .withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.themeData.colorScheme.error
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.trash2,
                          size: 22,
                          color: context.themeData.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Uninstall',
                          style:
                              context.themeData.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: context.themeData.colorScheme.error,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: context.themeData.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Privacy Section Header
        Container(
          width: double.infinity,
          height: 1,
          color: context.themeData.colorScheme.outline.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: context.themeData.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.shield,
                size: 18,
                color: context.themeData.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                context.localization.privacy,
                style: context.themeData.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Privacy Settings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Implement privacy settings
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeData.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeData.colorScheme.outline
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeData.colorScheme.secondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.pause,
                            size: 22,
                            color: context.themeData.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            context.localization.pauseListenHistory,
                            style:
                                context.themeData.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Switch(
                          value: data.pauseListenHistory,
                          onChanged: (value) {
                            settingsController.methods.setPauseListenHistory(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Implement search history settings
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeData.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeData.colorScheme.outline
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeData.colorScheme.secondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.search,
                            size: 22,
                            color: context.themeData.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            context.localization.pauseSearchHistory,
                            style:
                                context.themeData.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Switch(
                          value: data.pauseSearchHistory,
                          onChanged: (value) {
                            settingsController.methods.setPauseSearchHistory(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Implement screenshot settings
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeData.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeData.colorScheme.outline
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeData.colorScheme.secondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.camera,
                            size: 22,
                            color: context.themeData.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            context.localization.disableScreenshot,
                            style:
                                context.themeData.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Switch(
                          value: data.disableScreenshot,
                          onChanged: (value) {
                            settingsController.methods.setDisableScreenshot(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Storage Section Header
        Container(
          width: double.infinity,
          height: 1,
          color: context.themeData.colorScheme.outline.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: context.themeData.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.hardDrive,
                size: 18,
                color: context.themeData.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                context.localization.storage,
                style: context.themeData.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Storage Settings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showCacheSizeSheet(
                      context,
                      isImage: true,
                      currentValue: data.maxImageCacheSize,
                      onSelected: settingsController.methods.setMaxImageCacheSize,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeData.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeData.colorScheme.outline
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeData.colorScheme.tertiary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.image,
                            size: 22,
                            color: context.themeData.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.localization.imageCacheSize,
                                style:
                                    context.themeData.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${data.maxImageCacheSize} MB',
                                style: context.themeData.textTheme.bodyMedium?.copyWith(
                                  color: context.themeData.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 20,
                          color: context.themeData.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showCacheSizeSheet(
                      context,
                      isImage: false,
                      currentValue: data.maxSongCacheSize,
                      onSelected: settingsController.methods.setMaxSongCacheSize,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeData.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.themeData.colorScheme.outline
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeData.colorScheme.tertiary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.music,
                            size: 22,
                            color: context.themeData.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.localization.songCacheSize,
                                style:
                                    context.themeData.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${data.maxSongCacheSize} MB',
                                style: context.themeData.textTheme.bodyMedium?.copyWith(
                                  color: context.themeData.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 20,
                          color: context.themeData.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ],
      );
    });
  }
}

void _showCacheSizeSheet(
  BuildContext context, {
  required bool isImage,
  required int currentValue,
  required ValueChanged<int> onSelected,
}) {
  final options = isImage ? [50, 100, 200, 300] : [500, 1000, 2000, 4000];
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: context.themeData.colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isImage
                  ? context.localization.imageCacheSize
                  : context.localization.songCacheSize,
              style: context.themeData.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (value) => RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                value: value,
                // ignore: deprecated_member_use
                groupValue: currentValue,
                title: Text('$value MB'),
                // ignore: deprecated_member_use
                onChanged: (val) {
                  if (val != null) {
                    onSelected(val);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.confirm,
              style: context.themeData.textTheme.bodySmall?.copyWith(
                color: context.themeData.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    },
  );
}
