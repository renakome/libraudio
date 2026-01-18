import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:musily/core/presenter/ui/utils/ly_page.dart';
import 'package:musily/core/presenter/widgets/musily_app_bar.dart';
import 'package:musily/core/presenter/extensions/build_context.dart';
import '../controllers/radio_controller.dart';
import '../../domain/entities/radio_station.dart';
import '../../domain/entities/radio_category.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  final TextEditingController _searchController = TextEditingController();
  late RadioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RadioController(null as dynamic); // TODO: Inject via Modular
    // Controller já inicializa automaticamente no construtor
    _loadSmartRadioCategories();
  }

  void _loadSmartRadioCategories() {
    // Adiciona categorias inteligentes à lista existente
    final smartCategories = [
      const RadioCategory(
        id: 'smart_current',
        name: 'smartCurrentRadio',
        description: 'smartCurrentRadioDescription',
      ),
      const RadioCategory(
        id: 'smart_popular',
        name: 'smartPopularRadio',
        description: 'smartPopularRadioDescription',
      ),
      const RadioCategory(
        id: 'smart_discovery',
        name: 'smartDiscoveryRadio',
        description: 'smartDiscoveryRadioDescription',
      ),
    ];

    // Adiciona as categorias inteligentes às categorias existentes
    _controller.updateData(
      _controller.data.copyWith(
        categories: [..._controller.data.categories, ...smartCategories],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.builder(
      builder: (context, data) {
        return LyPage(
          contextKey: 'RadioPage',
          child: Scaffold(
            appBar: MusilyAppBar(
              title: Text(context.localization.radio),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: context.localization.searchStations,
                        prefixIcon: const Icon(LucideIcons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: context.themeData.colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (query) {
                        _controller.methods.searchStations(query);
                      },
                    ),
                  ),

                  // Content
                  Expanded(
                    child                        : data.isLoading && data.categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  context.localization.radioLoading,
                                  style: context.themeData.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : data.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.x,
                                      size: 48,
                                      color: context.themeData.colorScheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      context.localization.radioError,
                                      style: context.themeData.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data.error!,
                                      style: context.themeData.textTheme.bodyMedium?.copyWith(
                                        color: context.themeData.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? _buildSearchResults(data.searchResults)
                                : _buildCategoriesList(data.categories, data.stations, data.selectedCategoryId),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList(List<RadioCategory> categories, List<RadioStation> stations, String? selectedCategoryId) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Category Header
            InkWell(
              onTap: () {
                _controller.methods.loadStationsByCategory(category.id);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.themeData.colorScheme.primaryContainer
                      : context.themeData.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.themeData.colorScheme.primary
                        : context.themeData.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.radio,
                      size: 24,
                      color: isSelected
                          ? context.themeData.colorScheme.primary
                          : context.themeData.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedCategoryName(category.name),
                            style: context.themeData.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (category.description != null)
                            Text(
                              category.description!,
                              style: context.themeData.textTheme.bodySmall?.copyWith(
                                color: context.themeData.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      color: context.themeData.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Stations List (if category is selected)
            if (isSelected && stations.isNotEmpty)
              ...stations.map((station) => _buildStationTile(station)),
          ],
        );
      },
    );
  }

  String _getLocalizedCategoryName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'popular':
        return context.localization.popularStations;
      case 'news':
        return context.localization.newsStations;
      case 'music':
        return context.localization.musicStations;
      case 'jazz':
        return context.localization.jazzStations;
      case 'smart_current':
        return context.localization.smartCurrentRadio;
      case 'smart_popular':
        return context.localization.smartPopularRadio;
      case 'smart_discovery':
        return context.localization.smartDiscoveryRadio;
      default:
        return categoryName;
    }
  }

  Widget _buildSearchResults(List<RadioStation> searchResults) {
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 48,
              color: context.themeData.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.localization.noStationsFound,
              style: context.themeData.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _buildStationTile(searchResults[index]);
      },
    );
  }

  Widget _buildStationTile(RadioStation station) {
    final isPlaying = station.id == _controller.data.currentPlayingStation?.id;
    final isSmartStation = station.id.startsWith('smart_');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.themeData.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeData.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSmartStation
                ? context.themeData.colorScheme.secondaryContainer
                : context.themeData.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSmartStation ? LucideIcons.radio : (isPlaying ? LucideIcons.pause : LucideIcons.play),
            color: isSmartStation
                ? context.themeData.colorScheme.secondary
                : context.themeData.colorScheme.primary,
          ),
        ),
        title: Text(
          station.name,
          style: context.themeData.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (station.description != null)
              Text(
                station.description!,
                style: context.themeData.textTheme.bodySmall?.copyWith(
                  color: context.themeData.colorScheme.onSurfaceVariant,
                ),
              ),
            if (station.genre != null || station.country != null)
              Text(
                '${station.genre ?? ''} ${station.country != null ? '• ${station.country}' : ''}'.trim(),
                style: context.themeData.textTheme.bodySmall?.copyWith(
                  color: context.themeData.colorScheme.onSurfaceVariant,
                ),
              ),
            if (station.bitrate != null)
              Text(
                '${station.bitrate} kbps',
                style: context.themeData.textTheme.bodySmall?.copyWith(
                  color: context.themeData.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isSmartStation ? LucideIcons.radio : (isPlaying ? LucideIcons.pause : LucideIcons.play),
            color: isSmartStation
                ? context.themeData.colorScheme.secondary
                : context.themeData.colorScheme.primary,
          ),
          onPressed: () {
            if (isSmartStation) {
              _startSmartRadio(station);
            } else {
              if (isPlaying) {
                _controller.methods.stopPlayback();
              } else {
                _controller.methods.playStation(station);
              }
            }
          },
        ),
        onTap: () {
          if (isSmartStation) {
            _startSmartRadio(station);
          } else {
            if (isPlaying) {
              _controller.methods.stopPlayback();
            } else {
              _controller.methods.playStation(station);
            }
          }
        },
      ),
    );
  }

  void _startSmartRadio(RadioStation station) {
    // Aqui seria integrada com o player para iniciar rádio inteligente
    // Por enquanto, apenas mostra uma mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.localization.startRadio),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
