/// Status values for TV shows
class ShowStatus {
  /// The show is currently airing new episodes
  static const String returningSeries = 'returning series';

  /// The show is still in production
  static const String inProduction = 'in production';

  /// The show is planned for future release
  static const String planned = 'planned';

  /// The show is upcoming
  static const String upcoming = 'upcoming';

  /// The show is a pilot episode
  static const String pilot = 'pilot';

  /// The show has been canceled
  static const String canceled = 'canceled';

  /// The show has ended
  static const String ended = 'ended';

  /// List of all possible status values
  static const List<String> all = [
    returningSeries,
    inProduction,
    planned,
    upcoming,
    pilot,
    canceled,
    ended,
  ];

  /// Check if a status indicates the show is still active
  static bool isActive(String status) {
    return [
      returningSeries,
      inProduction,
      planned,
      upcoming,
      pilot,
    ].contains(status);
  }

  /// Check if a status indicates the show has ended
  static bool isEnded(String status) {
    return [
      canceled,
      ended,
    ].contains(status);
  }
}
