import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import 'package:musily/core/presenter/widgets/app_image.dart';

class PlayerBackground extends StatelessWidget {
  final String imageUrl;
  final String? lowResImageUrl;

  const PlayerBackground({
    super.key,
    required this.imageUrl,
    this.lowResImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = (lowResImageUrl?.isNotEmpty ?? false)
        ? lowResImageUrl!
        : imageUrl;

    return SizedBox(
      width: context.display.width,
      height: context.display.height,
      child: RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
            if (backgroundUrl.isNotEmpty)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: AppImage(
                  backgroundUrl,
                  fit: BoxFit.cover,
                ),
              )
            else
          Container(
            decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.themeData.colorScheme.primary
                          .withValues(alpha: 0.12),
                      context.themeData.colorScheme.secondary
                          .withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            // Overlay gradients for contrast/adaptação
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.themeData.colorScheme.surface
                          .withValues(alpha: 0.35),
                      context.themeData.colorScheme.surface
                          .withValues(alpha: 0.55),
                      context.themeData.colorScheme.surface
                          .withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.05,
                    colors: [
                      context.themeData.colorScheme.surface
                          .withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
