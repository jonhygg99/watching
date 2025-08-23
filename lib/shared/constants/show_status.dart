import 'package:watching/l10n/app_localizations.dart';

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

  /// Get the translated status string based on the status value
  static String getTranslatedStatus(String status, AppLocalizations l10n) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('returning')) {
      return l10n.showStatusReturningSeries;
    } else if (statusLower.contains('production')) {
      return l10n.showStatusInProduction;
    } else if (statusLower.contains('planned')) {
      return l10n.showStatusPlanned;
    } else if (statusLower.contains('upcoming')) {
      return l10n.showStatusUpcoming;
    } else if (statusLower.contains('pilot')) {
      return l10n.showStatusPilot;
    } else if (statusLower.contains('cancel')) {
      return l10n.showStatusCanceled;
    } else if (statusLower.contains('ended')) {
      return l10n.showStatusEnded;
    }
    return status;
  }
}
