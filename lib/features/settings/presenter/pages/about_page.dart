import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import 'package:musily/core/presenter/ui/utils/ly_page.dart';
import 'package:musily/core/presenter/widgets/empty_state.dart';
import 'package:musily/core/presenter/widgets/musily_app_bar.dart';
import 'package:musily/core/presenter/ui/buttons/ly_tonal_button.dart';
import 'package:musily/features/settings/domain/entities/supporter_entity.dart';
import 'package:musily/features/settings/presenter/controllers/settings/settings_controller.dart';
import 'package:musily/features/settings/presenter/widgets/supporter_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final SettingsController controller;
  const AboutPage({
    super.key,
    required this.controller,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.methods.loadSupporters();
    });
  }

  Future<void> _refresh() {
    return widget.controller.methods.loadSupporters(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return LyPage(
      contextKey: 'AboutPage',
      child: widget.controller.builder(builder: (context, data) {
        final List<SupporterEntity> supporters = data.supporters;
        final bool isLoading = data.loadingSupporters && supporters.isEmpty;
        final bool showSupporters = data.showSupporters;

        return Scaffold(
          appBar: MusilyAppBar(
            title: Text(context.localization.about),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const _AboutHeader(),
                  const SizedBox(height: 24),
                  const _AboutActions(),
                  const SizedBox(height: 24),
                  _SupportersToggle(
                    value: showSupporters,
                    onChanged: (value) =>
                        widget.controller.methods.setShowSupporters(value),
                  ),
                  if (showSupporters) ...[
                    const SizedBox(height: 24),
                  const _SupportersSectionTitle(),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const _SupportersLoading()
                  else if (supporters.isEmpty)
                    EmptyState(
                      title: context.localization.supportersEmpty,
                      icon: Icon(
                        LucideIcons.heartHandshake,
                        color: context.themeData.colorScheme.primary,
                      ),
                    )
                  else
                    ...supporters.map(
                      (supporter) => SupporterTile(
                        supporter: supporter,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/libraudio.svg',
          width: 72,
        ),
        const SizedBox(height: 16),
        Text(
          'Libraudio',
          style: context.themeData.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by Renako',
          style: context.themeData.textTheme.bodyLarge?.copyWith(
            color:
                context.themeData.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AboutActions extends StatelessWidget {
  const _AboutActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LyTonalButton(
            onPressed: () async {
              final uri = Uri.parse('https://github.com/renakome');
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Image.asset(
              'assets/icons/github.png',
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LyTonalButton(
            onPressed: () async {
              final uri = Uri.parse('https://t.me/renako_me');
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Image.asset(
              'assets/icons/telegram.png',
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LyTonalButton(
            onPressed: () async {
              final uri = Uri.parse('https://twitter.com/renako_me');
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Image.asset(
              'assets/icons/twitter.png',
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportersToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SupportersToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.themeData.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.themeData.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.users,
            size: 18,
            color: context.themeData.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mostrar apoiadores',
              style: context.themeData.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SupportersSectionTitle extends StatelessWidget {
  const _SupportersSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
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
          LucideIcons.users,
          size: 18,
          color: context.themeData.colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Text(
          context.localization.supportersTitle,
          style: context.themeData.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _SupportersLoading extends StatelessWidget {
  const _SupportersLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: context.themeData.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
