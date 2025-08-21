class Episode {
  final String? id;
  final String? title;
  final int season;
  final int number;
  final String? overview;
  final double? rating;
  final int? runtime;
  final bool watched;
  final Map<String, dynamic>? images;

  Episode({
    this.id,
    this.title,
    required this.season,
    required this.number,
    this.overview,
    this.rating,
    this.runtime,
    this.watched = false,
    this.images,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString(),
      title: json['title'],
      season: json['season'] ?? 0,
      number: json['number'] ?? 0,
      overview: json['overview'],
      rating: json['rating']?.toDouble(),
      runtime: json['runtime'],
      watched: json['watched'] == true,
      images: json['images'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'season': season,
      'number': number,
      'overview': overview,
      'rating': rating,
      'runtime': runtime,
      'watched': watched,
      'images': images,
    };
  }
}
