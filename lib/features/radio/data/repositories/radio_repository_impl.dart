import '../../domain/repositories/radio_repository.dart';
import '../../domain/entities/radio_station.dart';
import '../../domain/entities/radio_category.dart';
import '../datasources/radio_datasource.dart';

class RadioRepositoryImpl implements RadioRepository {
  final RadioDataSource dataSource;

  RadioRepositoryImpl(this.dataSource);

  @override
  Future<List<RadioCategory>> getRadioCategories() async {
    return await dataSource.getRadioCategories();
  }

  @override
  Future<List<RadioStation>> getStationsByCategory(String categoryId) async {
    return await dataSource.getStationsByCategory(categoryId);
  }

  @override
  Future<List<RadioStation>> searchStations(String query) async {
    return await dataSource.searchStations(query);
  }

  @override
  Future<List<RadioStation>> getPopularStations() async {
    return await dataSource.getPopularStations();
  }

  @override
  Future<List<RadioStation>> getStationsByCountry(String country) async {
    return await dataSource.getStationsByCountry(country);
  }

  @override
  Future<List<RadioStation>> getStationsByGenre(String genre) async {
    return await dataSource.getStationsByGenre(genre);
  }
}
