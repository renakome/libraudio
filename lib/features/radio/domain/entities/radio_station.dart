class RadioStation {
  final String id;
  final String name;
  final String url;
  final String? country;
  final String? language;
  final String? genre;
  final String? description;
  final String? logoUrl;
  final int? bitrate;

  const RadioStation({
    required this.id,
    required this.name,
    required this.url,
    this.country,
    this.language,
    this.genre,
    this.description,
    this.logoUrl,
    this.bitrate,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      country: json['country'],
      language: json['language'],
      genre: json['genre'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      bitrate: json['bitrate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'country': country,
      'language': language,
      'genre': genre,
      'description': description,
      'logoUrl': logoUrl,
      'bitrate': bitrate,
    };
  }
}
