import 'trakt_id.dart';
import 'show_models.dart';

/// Model for a show summary response from Trakt API
class ShowSummary extends TraktShow {
  /// The show's tagline
  final String? tagline;

  /// When the show airs
  final Map<String, dynamic>? airs;

  /// Number of comments
  final int? commentCount;

  /// List of available translations
  final List<String>? availableTranslations;

  /// Original title (for non-english shows)
  final String? originalTitle;

  const ShowSummary({
    required super.title,
    required super.year,
    required super.ids,
    super.images,
    super.overview,
    super.status,
    super.rating,
    super.votes,
    super.runtime,
    super.certification,
    super.network,
    super.country,
    super.trailer,
    super.homepage,
    super.language,
    super.genres,
    super.airedEpisodes,
    super.firstAired,
    super.updatedAt,
    super.watchers,
    super.watcherCount,
    super.playCount,
    super.collectedCount,
    super.userCount,
    this.tagline,
    this.airs,
    this.commentCount,
    this.availableTranslations,
    this.originalTitle,
  });

  /// Creates a ShowSummary from JSON
  factory ShowSummary.fromJson(Map<String, dynamic> json) {
    return ShowSummary(
      title: json['title'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      ids: TraktId.fromJson(json['ids'] as Map<String, dynamic>),
      images: json['images'] != null
          ? Map<String, List<String>>.from(
              (json['images'] as Map).map((key, value) => MapEntry(
                    key.toString(),
                    (value as List<dynamic>).map((e) => e.toString()).toList(),
                  )))
          : null,
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
      tagline: json['tagline'] as String?,
      airs: json['airs'] != null
          ? Map<String, dynamic>.from(json['airs'] as Map)
          : null,
      commentCount: json['comment_count'] as int?,
      availableTranslations: json['available_translations'] != null
          ? List<String>.from(json['available_translations'] as List)
          : null,
      originalTitle: json['original_title'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (tagline != null) 'tagline': tagline,
        if (airs != null) 'airs': airs,
        if (commentCount != null) 'comment_count': commentCount,
        if (availableTranslations != null)
          'available_translations': availableTranslations,
        if (originalTitle != null) 'original_title': originalTitle,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ShowSummary &&
          runtimeType == other.runtimeType &&
          tagline == other.tagline &&
          airs == other.airs &&
          commentCount == other.commentCount &&
          availableTranslations == other.availableTranslations &&
          originalTitle == other.originalTitle;

  @override
  int get hashCode =>
      super.hashCode ^
      tagline.hashCode ^
      airs.hashCode ^
      commentCount.hashCode ^
      availableTranslations.hashCode ^
      originalTitle.hashCode;

  @override
  String toString() => 'ShowSummary($title, $year, $ids, tagline: $tagline)';
}
