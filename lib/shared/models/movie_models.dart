import 'package:flutter/material.dart';
import 'trakt_id.dart';

/// Model for a movie from Trakt API
class TraktMovie {
  final String title;
  final int? year;
  final TraktId ids;
  final Map<String, dynamic>? images;

  const TraktMovie({
    required this.title,
    this.year,
    required this.ids,
    this.images,
  });

  factory TraktMovie.fromJson(Map<String, dynamic> json) {
    try {
      return TraktMovie(
        title: json['title'] as String,
        year: json['year'] as int?,
        ids: TraktId.fromJson(json['ids'] as Map<String, dynamic>),
        images: json['images'] != null
            ? Map<String, dynamic>.from(
                (json['images'] as Map).map((key, value) => MapEntry(
                      key.toString(),
                      value is List ? value : [value.toString()],
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
        if (year != null) 'year': year,
        'ids': ids.toJson(),
        if (images != null) 'images': images,
      };

  @override
  String toString() => 'TraktMovie($title, ${ids.trakt})';
}
