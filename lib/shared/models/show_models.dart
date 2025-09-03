import 'trakt_id.dart';

/// Model for a show from Trakt API
class TraktShow {
  final String title;
  final int year;
  final TraktId ids;
  final Map<String, List<String>>? images;
  final String? overview;
  final String? status;
  final double? rating;
  final int? votes;
  final int? runtime;
  final String? certification;
  final String? network;
  final String? country;
  final String? trailer;
  final String? homepage;
  final String? language;
  final List<String>? genres;
  final int? airedEpisodes;
  final String? firstAired;
  final String? updatedAt;
  final int? watchers;
  final int? watcherCount;
  final int? playCount;
  final int? collectedCount;
  final int? userCount;

  const TraktShow({
    required this.title,
    required this.year,
    required this.ids,
    this.images,
    this.overview,
    this.status,
    this.rating,
    this.votes,
    this.runtime,
    this.certification,
    this.network,
    this.country,
    this.trailer,
    this.homepage,
    this.language,
    this.genres,
    this.airedEpisodes,
    this.firstAired,
    this.updatedAt,
    this.watchers,
    this.watcherCount,
    this.playCount,
    this.collectedCount,
    this.userCount,
  });

  factory TraktShow.fromJson(Map<String, dynamic> json) {
    return TraktShow(
      title: json['title'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      ids: TraktId.fromJson(json['ids'] as Map<String, dynamic>),
      images: json['images'] != null ? Map<String, List<String>>.from(
        (json['images'] as Map).map((key, value) => MapEntry(
          key.toString(),
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        )),
      ) : null,
      overview: json['overview'] as String?,
      status: json['status'] as String?,
      rating: json['rating']?.toDouble(),
      votes: json['votes'] as int?,
      runtime: json['runtime'] as int?,
      certification: json['certification'] as String?,
      network: json['network'] as String?,
      country: json['country'] as String?,
      trailer: json['trailer'] as String?,
      homepage: json['homepage'] as String?,
      language: json['language'] as String?,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : null,
      airedEpisodes: json['aired_episodes'] as int?,
      firstAired: json['first_aired'] as String?,
      updatedAt: json['updated_at'] as String?,
      watchers: json['watchers'] as int?,
      watcherCount: json['watcher_count'] as int?,
      playCount: json['play_count'] as int?,
      collectedCount: json['collected_count'] as int?,
      userCount: json['user_count'] as int?,
    );
  }

  /// Creates a TraktShow from a nested API response (e.g., from 'show' field)
  factory TraktShow.fromNestedJson(
    Map<String, dynamic> json, {
    bool isNested = true,
  }) {
    final showData = isNested ? json['show'] ?? json : json;
    return TraktShow.fromJson({
      ...showData,
      'watchers': json['watchers'],
      'watcher_count': json['watcher_count'],
      'play_count': json['play_count'],
      'collected_count': json['collected_count'],
      'user_count': json['user_count'],
    });
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'year': year,
        'ids': ids.toJson(),
        if (images != null) 'images': images,
        if (overview != null) 'overview': overview,
        if (status != null) 'status': status,
        if (rating != null) 'rating': rating,
        if (votes != null) 'votes': votes,
        if (runtime != null) 'runtime': runtime,
        if (certification != null) 'certification': certification,
        if (network != null) 'network': network,
        if (country != null) 'country': country,
        if (trailer != null) 'trailer': trailer,
        if (homepage != null) 'homepage': homepage,
        if (language != null) 'language': language,
        if (genres != null) 'genres': genres,
        if (airedEpisodes != null) 'aired_episodes': airedEpisodes,
        if (firstAired != null) 'first_aired': firstAired,
        if (updatedAt != null) 'updated_at': updatedAt,
        if (watchers != null) 'watchers': watchers,
        if (watcherCount != null) 'watcher_count': watcherCount,
        if (playCount != null) 'play_count': playCount,
        if (collectedCount != null) 'collected_count': collectedCount,
        if (userCount != null) 'user_count': userCount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraktShow &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          year == other.year &&
          ids == other.ids;

  @override
  int get hashCode => title.hashCode ^ year.hashCode ^ ids.hashCode;

  @override
  String toString() => 'TraktShow($title, $year, $ids)';
}

/// Extension methods for list operations on TraktShow
extension TraktShowListExtensions on List<TraktShow> {
  /// Creates a list of TraktShow from a list of JSON objects
  static List<TraktShow> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => TraktShow.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Creates a list of TraktShow from a list of nested JSON objects
  static List<TraktShow> fromNestedJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => TraktShow.fromNestedJson(item as Map<String, dynamic>))
        .toList();
  }
}
