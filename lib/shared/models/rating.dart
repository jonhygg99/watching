/// Represents a rating with its distribution from Trakt API.
class Rating {
  /// Creates a new [Rating] instance.
  const Rating({
    required this.rating,
    required this.votes,
    required this.distribution,
  });

  /// Creates a [Rating] from JSON data.
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: (json['rating'] as num).toDouble(),
      votes: json['votes'] as int,
      distribution: Map<String, int>.from(
        (json['distribution'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as int),
        ),
      ),
    );
  }

  /// The average rating.
  final double rating;

  /// The total number of votes.
  final int votes;

  /// The distribution of votes across different ratings (1-10).
  final Map<String, int> distribution;

  /// Converts this [Rating] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'votes': votes,
      'distribution': Map<String, int>.from(distribution),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rating &&
        other.runtimeType == runtimeType &&
        other.rating == rating &&
        other.votes == votes &&
        _mapsEqual(other.distribution, distribution);
  }

  @override
  int get hashCode => Object.hash(rating, votes, distribution);

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() => 'Rating(rating: $rating, votes: $votes, distribution: $distribution)';
}
