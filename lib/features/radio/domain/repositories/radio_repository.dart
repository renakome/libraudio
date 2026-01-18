import '../entities/radio_station.dart';
import '../entities/radio_category.dart';

abstract class RadioRepository {
  Future<List<RadioCategory>> getRadioCategories();
  Future<List<RadioStation>> getStationsByCategory(String categoryId);
  Future<List<RadioStation>> searchStations(String query);
  Future<List<RadioStation>> getPopularStations();
  Future<List<RadioStation>> getStationsByCountry(String country);
  Future<List<RadioStation>> getStationsByGenre(String genre);
}
