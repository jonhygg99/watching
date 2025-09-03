import 'package:flutter/material.dart';

/// Model for a movie ID from Trakt API
class TraktMovieId {
  final int trakt;
  final String slug;
  final String imdb;
  final int tmdb;

  const TraktMovieId({
    required this.trakt,
    required this.slug,
    required this.imdb,
    required this.tmdb,
  });

  factory TraktMovieId.fromJson(Map<String, dynamic> json) {
    return TraktMovieId(
      trakt: json['trakt'] as int,
      slug: json['slug'] as String,
      imdb: json['imdb'] as String,
      tmdb: json['tmdb'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'trakt': trakt,
        'slug': slug,
        'imdb': imdb,
        'tmdb': tmdb,
      };

  @override
  String toString() => 'TraktMovieId($trakt, $slug, $imdb, $tmdb)';
}

/// Model for a movie from Trakt API
class TraktMovie {
  final String title;
  final TraktMovieId ids;
  final Map<String, String>? images;

  const TraktMovie({
    required this.title,
    required this.ids,
    this.images,
  });

  factory TraktMovie.fromJson(Map<String, dynamic> json) {
    try {
      return TraktMovie(
        title: json['title']?.toString() ?? 'Unknown Title',
        ids: json['ids'] != null
            ? TraktMovieId.fromJson(
                Map<String, dynamic>.from(json['ids'] as Map))
            : const TraktMovieId(trakt: 0, slug: '', imdb: '', tmdb: 0),
        images: json['images'] != null
            ? Map<String, String>.from(
                (json['images'] as Map).map((key, value) => MapEntry(
                      key.toString(),
                      value is String ? value : value.toString(),
                    )))
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing TraktMovie: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'ids': ids.toJson(),
        if (images != null) 'images': images,
      };

  @override
  String toString() => 'TraktMovie($title, ${ids.trakt})';
}
