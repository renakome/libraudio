import 'dart:convert';
import 'package:http/http.dart' as http;
import 'radio_datasource.dart';
import '../../domain/entities/radio_station.dart';
import '../../domain/entities/radio_category.dart';

class RadioDataSourceImpl implements RadioDataSource {
  // Radio Browser API base URL
  static const String _baseUrl = 'https://de1.api.radio-browser.info';

  // Cache para evitar muitas requisições
  final Map<String, List<RadioStation>> _cache = {};
  final Map<String, List<RadioCategory>> _categoryCache = {};

  // Dados de fallback caso a API falhe
  final List<RadioStation> _fallbackStations = const [
    RadioStation(
      id: 'fallback-1',
      name: 'BBC Radio 1',
      url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
      country: 'UK',
      genre: 'Pop',
      description: 'BBC Radio 1 - The best new music',
      bitrate: 128,
    ),
    RadioStation(
      id: 'fallback-2',
      name: 'Capital FM',
      url: 'https://media-ssl.musicradio.com/Capital',
      country: 'UK',
      genre: 'Pop',
      description: 'Capital FM - London\'s No.1 Hit Music Station',
      bitrate: 128,
    ),
    RadioStation(
      id: 'fallback-3',
      name: 'Jazz24',
      url: 'https://live.wostreaming.net/direct/ppm-jazz24mp3-ibc3',
      country: 'USA',
      genre: 'Jazz',
      description: 'Jazz24 - The Sound of Jazz',
      bitrate: 128,
    ),
  ];

  final List<RadioCategory> _fallbackCategories = const [
    RadioCategory(
      id: 'popular',
      name: 'Popular',
      description: 'Most listened stations',
    ),
    RadioCategory(
      id: 'news',
      name: 'News',
      description: 'News and information stations',
    ),
    RadioCategory(
      id: 'music',
      name: 'Music',
      description: 'Various music stations',
    ),
    RadioCategory(
      id: 'jazz',
      name: 'Jazz',
      description: 'Jazz stations',
    ),
  ];

  @override
  Future<List<RadioCategory>> getRadioCategories() async {
    if (_categoryCache.containsKey('categories')) {
      return _categoryCache['categories']!;
    }

    try {
      // Buscar tags/genres mais populares da API
      final response = await http.get(
        Uri.parse('$_baseUrl/json/tags?limit=20&order=stationcount&reverse=true'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> tags = json.decode(response.body);

        final categories = tags.take(8).map((tag) {
          final tagName = tag['name'] as String;
          return RadioCategory(
            id: tagName.toLowerCase(),
            name: _capitalizeFirst(tagName),
            description: '${tag['stationcount']} stations',
          );
        }).toList();

        _categoryCache['categories'] = categories;
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Fallback para categorias padrão
      _categoryCache['categories'] = _fallbackCategories;
      return _fallbackCategories;
    }
  }

  @override
  Future<List<RadioStation>> getStationsByCategory(String categoryId) async {
    final cacheKey = 'category_$categoryId';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      // Buscar estações por tag/gênero
      final response = await http.get(
        Uri.parse('$_baseUrl/json/stations/bytagexact/${Uri.encodeComponent(categoryId)}?limit=50&order=votes&reverse=true'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> stations = json.decode(response.body);

        final radioStations = stations
            .where((station) => station['url'] != null && station['url'].isNotEmpty)
            .take(20)
            .map((station) => RadioStation(
                  id: station['stationuuid'] ?? station['changeuuid'] ?? '',
                  name: station['name'] ?? 'Unknown Station',
                  url: station['url'],
                  country: station['country'],
                  genre: station['tags']?.split(',')?.first,
                  description: station['homepage'] != null && station['homepage'].isNotEmpty
                      ? 'Visit website'
                      : null,
                  logoUrl: station['favicon'] != null && station['favicon'].isNotEmpty
                      ? station['favicon']
                      : null,
                  bitrate: station['bitrate'] != null
                      ? int.tryParse(station['bitrate'].toString())
                      : null,
                ))
            .toList();

        _cache[cacheKey] = radioStations;
        return radioStations;
      } else {
        throw Exception('Failed to load stations for category: $categoryId');
      }
    } catch (e) {
      // Fallback baseado na categoria
      final fallbackStations = _getFallbackStationsByCategory(categoryId);
      _cache[cacheKey] = fallbackStations;
      return fallbackStations;
    }
  }

  @override
  Future<List<RadioStation>> searchStations(String query) async {
    if (query.isEmpty) return [];

    final cacheKey = 'search_$query';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/stations/search?name=${Uri.encodeComponent(query)}&limit=30&order=votes&reverse=true'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> stations = json.decode(response.body);

        final radioStations = stations
            .where((station) => station['url'] != null && station['url'].isNotEmpty)
            .take(20)
            .map((station) => RadioStation(
                  id: station['stationuuid'] ?? station['changeuuid'] ?? '',
                  name: station['name'] ?? 'Unknown Station',
                  url: station['url'],
                  country: station['country'],
                  genre: station['tags']?.split(',')?.first,
                  description: station['homepage'] != null && station['homepage'].isNotEmpty
                      ? 'Visit website'
                      : null,
                  logoUrl: station['favicon'] != null && station['favicon'].isNotEmpty
                      ? station['favicon']
                      : null,
                  bitrate: station['bitrate'] != null
                      ? int.tryParse(station['bitrate'].toString())
                      : null,
                ))
            .toList();

        _cache[cacheKey] = radioStations;
        return radioStations;
      } else {
        throw Exception('Failed to search stations');
      }
    } catch (e) {
      // Fallback para busca local nos dados de exemplo
      final lowercaseQuery = query.toLowerCase();
      final fallbackResults = _fallbackStations.where((station) =>
          station.name.toLowerCase().contains(lowercaseQuery) ||
          station.genre?.toLowerCase().contains(lowercaseQuery) == true ||
          station.country?.toLowerCase().contains(lowercaseQuery) == true
      ).toList();
      _cache[cacheKey] = fallbackResults;
      return fallbackResults;
    }
  }

  @override
  Future<List<RadioStation>> getPopularStations() async {
    const cacheKey = 'popular';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/stations/topvote/20'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> stations = json.decode(response.body);

        final radioStations = stations
            .where((station) => station['url'] != null && station['url'].isNotEmpty)
            .map((station) => RadioStation(
                  id: station['stationuuid'] ?? station['changeuuid'] ?? '',
                  name: station['name'] ?? 'Unknown Station',
                  url: station['url'],
                  country: station['country'],
                  genre: station['tags']?.split(',')?.first,
                  description: station['homepage'] != null && station['homepage'].isNotEmpty
                      ? 'Visit website'
                      : null,
                  logoUrl: station['favicon'] != null && station['favicon'].isNotEmpty
                      ? station['favicon']
                      : null,
                  bitrate: station['bitrate'] != null
                      ? int.tryParse(station['bitrate'].toString())
                      : null,
                ))
            .toList();

        _cache[cacheKey] = radioStations;
        return radioStations;
      } else {
        throw Exception('Failed to load popular stations');
      }
    } catch (e) {
      _cache[cacheKey] = _fallbackStations;
      return _fallbackStations;
    }
  }

  @override
  Future<List<RadioStation>> getStationsByCountry(String country) async {
    final cacheKey = 'country_$country';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/stations/bycountryexact/${Uri.encodeComponent(country)}?limit=30&order=votes&reverse=true'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> stations = json.decode(response.body);

        final radioStations = stations
            .where((station) => station['url'] != null && station['url'].isNotEmpty)
            .take(15)
            .map((station) => RadioStation(
                  id: station['stationuuid'] ?? station['changeuuid'] ?? '',
                  name: station['name'] ?? 'Unknown Station',
                  url: station['url'],
                  country: station['country'],
                  genre: station['tags']?.split(',')?.first,
                  description: station['homepage'] != null && station['homepage'].isNotEmpty
                      ? 'Visit website'
                      : null,
                  logoUrl: station['favicon'] != null && station['favicon'].isNotEmpty
                      ? station['favicon']
                      : null,
                  bitrate: station['bitrate'] != null
                      ? int.tryParse(station['bitrate'].toString())
                      : null,
                ))
            .toList();

        _cache[cacheKey] = radioStations;
        return radioStations;
      } else {
        throw Exception('Failed to load stations by country');
      }
    } catch (e) {
      // Fallback baseado no país
      final fallbackStations = _fallbackStations
          .where((station) => station.country?.toLowerCase() == country.toLowerCase())
          .toList();
      _cache[cacheKey] = fallbackStations;
      return fallbackStations;
    }
  }

  @override
  Future<List<RadioStation>> getStationsByGenre(String genre) async {
    final cacheKey = 'genre_$genre';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/json/stations/bytagexact/${Uri.encodeComponent(genre)}?limit=30&order=votes&reverse=true'),
        headers: {'User-Agent': 'Musily/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> stations = json.decode(response.body);

        final radioStations = stations
            .where((station) => station['url'] != null && station['url'].isNotEmpty)
            .take(15)
            .map((station) => RadioStation(
                  id: station['stationuuid'] ?? station['changeuuid'] ?? '',
                  name: station['name'] ?? 'Unknown Station',
                  url: station['url'],
                  country: station['country'],
                  genre: station['tags']?.split(',')?.first,
                  description: station['homepage'] != null && station['homepage'].isNotEmpty
                      ? 'Visit website'
                      : null,
                  logoUrl: station['favicon'] != null && station['favicon'].isNotEmpty
                      ? station['favicon']
                      : null,
                  bitrate: station['bitrate'] != null
                      ? int.tryParse(station['bitrate'].toString())
                      : null,
                ))
            .toList();

        _cache[cacheKey] = radioStations;
        return radioStations;
      } else {
        throw Exception('Failed to load stations by genre');
      }
    } catch (e) {
      // Fallback baseado no gênero
      final fallbackStations = _fallbackStations
          .where((station) => station.genre?.toLowerCase() == genre.toLowerCase())
          .toList();
      _cache[cacheKey] = fallbackStations;
      return fallbackStations;
    }
  }

  List<RadioStation> _getFallbackStationsByCategory(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'news':
        return _fallbackStations.where((station) => station.genre == 'News').toList();
      case 'jazz':
        return _fallbackStations.where((station) => station.genre == 'Jazz').toList();
      case 'pop':
        return _fallbackStations.where((station) => station.genre == 'Pop').toList();
      default:
        return _fallbackStations.take(5).toList();
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
