import 'package:musily/core/domain/presenter/app_controller.dart';
import '../../domain/repositories/radio_repository.dart';
import '../../domain/entities/radio_station.dart';
import '../../domain/entities/radio_category.dart';

class RadioData implements BaseControllerData {
  final List<RadioCategory> categories;
  final List<RadioStation> stations;
  final List<RadioStation> searchResults;
  final bool isLoading;
  final String? error;
  final String? selectedCategoryId;
  final RadioStation? currentPlayingStation;

  const RadioData({
    this.categories = const [],
    this.stations = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.currentPlayingStation,
  });

  @override
  RadioData copyWith({
    List<RadioCategory>? categories,
    List<RadioStation>? stations,
    List<RadioStation>? searchResults,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
    RadioStation? currentPlayingStation,
  }) {
    return RadioData(
      categories: categories ?? this.categories,
      stations: stations ?? this.stations,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      currentPlayingStation: currentPlayingStation ?? this.currentPlayingStation,
    );
  }
}

class RadioMethods {
  final Future<void> Function() loadCategories;
  final Future<void> Function(String categoryId) loadStationsByCategory;
  final Future<void> Function(String query) searchStations;
  final void Function(RadioStation station) playStation;
  final void Function() stopPlayback;

  const RadioMethods({
    required this.loadCategories,
    required this.loadStationsByCategory,
    required this.searchStations,
    required this.playStation,
    required this.stopPlayback,
  });
}

class RadioController extends BaseController<RadioData, RadioMethods> {
  final RadioRepository repository;

  RadioController(this.repository) {
    // Initialize by loading categories
    methods.loadCategories();
  }

  @override
  RadioData defineData() {
    return const RadioData();
  }

  @override
  RadioMethods defineMethods() {
    return RadioMethods(
      loadCategories: _loadCategories,
      loadStationsByCategory: _loadStationsByCategory,
      searchStations: _searchStations,
      playStation: _playStation,
      stopPlayback: _stopPlayback,
    );
  }

  Future<void> _loadCategories() async {
    try {
      updateData(data.copyWith(isLoading: true, error: null));
      final categories = await repository.getRadioCategories();
      updateData(data.copyWith(
        categories: categories,
        isLoading: false,
      ));
    } catch (e) {
      updateData(data.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _loadStationsByCategory(String categoryId) async {
    try {
      updateData(data.copyWith(isLoading: true, error: null));

      if (categoryId.startsWith('smart_')) {
        // Lidar com categorias inteligentes
        final smartStations = _getSmartStations(categoryId);
        updateData(data.copyWith(
          stations: smartStations,
          selectedCategoryId: categoryId,
          isLoading: false,
        ));
      } else {
        // Comportamento original para categorias normais
        final stations = await repository.getStationsByCategory(categoryId);
        updateData(data.copyWith(
          stations: stations,
          selectedCategoryId: categoryId,
          isLoading: false,
        ));
      }
    } catch (e) {
      updateData(data.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  List<RadioStation> _getSmartStations(String categoryId) {
    // Retorna estações virtuais baseadas em categorias inteligentes
    switch (categoryId) {
      case 'smart_current':
        return [
          const RadioStation(
            id: 'smart_current_radio',
            name: 'smartCurrentRadio',
            url: '', // URL será gerada dinamicamente
            description: 'smartCurrentRadioDescription',
            genre: 'intelligentGenre',
          ),
        ];
      case 'smart_popular':
        return [
          const RadioStation(
            id: 'smart_popular_radio',
            name: 'smartPopularRadio',
            url: '', // URL será gerada dinamicamente
            description: 'smartPopularRadioDescription',
            genre: 'Popular',
          ),
        ];
      case 'smart_discovery':
        return [
          const RadioStation(
            id: 'smart_discovery_radio',
            name: 'smartDiscoveryRadio',
            url: '', // URL será gerada dinamicamente
            description: 'smartDiscoveryRadioDescription',
            genre: 'Discoveries',
          ),
        ];
      default:
        return [];
    }
  }

  Future<void> _searchStations(String query) async {
    if (query.isEmpty) {
      updateData(data.copyWith(searchResults: []));
      return;
    }

    try {
      updateData(data.copyWith(isLoading: true, error: null));
      final results = await repository.searchStations(query);
      updateData(data.copyWith(
        searchResults: results,
        isLoading: false,
      ));
    } catch (e) {
      updateData(data.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _playStation(RadioStation station) {
    updateData(data.copyWith(currentPlayingStation: station));
    // Aqui seria implementada a lógica de reprodução
    // Por enquanto apenas atualiza o estado
  }

  void _stopPlayback() {
    updateData(data.copyWith(currentPlayingStation: null));
    // Aqui seria implementada a lógica para parar a reprodução
  }
}
