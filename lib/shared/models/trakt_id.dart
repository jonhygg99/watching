/// Model for Trakt IDs (shows, movies, etc.)
class TraktId {
  final int trakt;
  final String slug;
  final String imdb;
  final int tmdb;
  final int? tvdb;

  const TraktId({
    required this.trakt,
    required this.slug,
    required this.imdb,
    required this.tmdb,
    this.tvdb,
  });

  /// Creates a TraktId for a show
  factory TraktId.show({
    required int trakt,
    required String slug,
    required String imdb,
    required int tmdb,
    int? tvdb,
  }) {
    return TraktId(
      trakt: trakt,
      slug: slug,
      imdb: imdb,
      tmdb: tmdb,
      tvdb: tvdb,
    );
  }

  /// Creates a TraktId for a movie
  factory TraktId.movie({
    required int trakt,
    required String slug,
    required String imdb,
    required int tmdb,
  }) {
    return TraktId(
      trakt: trakt,
      slug: slug,
      imdb: imdb,
      tmdb: tmdb,
      tvdb: null,
    );
  }

  factory TraktId.fromJson(Map<String, dynamic> json) {
    return TraktId(
      trakt: json['trakt'] as int,
      slug: json['slug'] as String,
      imdb: json['imdb'] as String? ?? '',
      tmdb: json['tmdb'] as int? ?? 0,
      tvdb: json['tvdb'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'trakt': trakt,
        'slug': slug,
        'imdb': imdb,
        'tmdb': tmdb,
        if (tvdb != null) 'tvdb': tvdb,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraktId &&
          runtimeType == other.runtimeType &&
          trakt == other.trakt &&
          slug == other.slug &&
          imdb == other.imdb &&
          tmdb == other.tmdb &&
          tvdb == other.tvdb;

  @override
  int get hashCode =>
      trakt.hashCode ^
      slug.hashCode ^
      imdb.hashCode ^
      tmdb.hashCode ^
      tvdb.hashCode;

  @override
  String toString() => 'TraktId($trakt, $slug, $imdb, $tmdb${tvdb != null ? ', $tvdb' : ''})';
}
