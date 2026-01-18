import 'radio_station.dart';

class RadioCategory {
  final String id;
  final String name;
  final String? description;
  final List<RadioStation> stations;

  const RadioCategory({
    required this.id,
    required this.name,
    this.description,
    this.stations = const [],
  });

  factory RadioCategory.fromJson(Map<String, dynamic> json) {
    return RadioCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      stations: (json['stations'] as List<dynamic>?)
              ?.map((station) => RadioStation.fromJson(station))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'stations': stations.map((station) => station.toJson()).toList(),
    };
  }
}
