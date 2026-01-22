/// Constants for watchlist functionality.
///
/// Contains processing parameters, animation durations, API delays,
/// UI dimensions, and error messages used throughout the watchlist feature.

/// Processing constants
class WatchlistProcessing {
  /// Number of items to process in each chunk during progressive loading
  static const int chunkSize = 5;
}

/// Animation and timing constants
class WatchlistAnimations {
  /// Duration for chunk processing animation in milliseconds
  static const int chunkProcessingDelayMs = 300;

  /// Delay for API server processing in seconds
  static const int apiProcessingDelayS = 1;
}

/// UI dimensions and spacing constants
class WatchlistDimensions {
  /// Vertical margin for show items
  static const double itemVerticalMargin = 5.0;

  /// Horizontal margin for show items
  static const double itemHorizontalMargin = 16.0;

  /// Horizontal padding for show item content
  static const double itemHorizontalPadding = 20.0;

  /// Icon width for episode actions
  static const double iconWidth = 24.0;

  /// Icon height for episode actions
  static const double iconHeight = 24.0;

  /// Stroke width for progress indicators
  static const double progressStrokeWidth = 2.5;
}

/// Error messages used across watchlist operations
class WatchlistErrorMessages {
  /// Error when no next episode is found to mark as watched
  static const String noNextEpisodeFound =
      'No next episode found to mark as watched';

  /// Error when no watched episodes are found to unwatch
  static const String noWatchedEpisodesFound =
      'No watched episodes found to unwatch';

  /// Error when required episode data is missing
  static const String missingEpisodeData = 'Missing required episode data';

  /// Error prefix for failed episode watch status updates
  static const String failedToUpdateEpisodeStatus =
      'Error al actualizar el estado del episodio';

  /// Error prefix for failed episode marking as watched
  static const String failedToMarkEpisodeWatched =
      'Failed to mark episode as watched';

  /// Error prefix for failed episode marking as unwatched
  static const String failedToMarkEpisodeUnwatched =
      'Failed to mark episode as unwatched';

  /// Error prefix for failed show progress updates
  static const String failedToUpdateShowProgress =
      'Failed to update show progress';

  /// Error prefix for failed watchlist refresh
  static const String failedToRefreshWatchlist = 'Failed to refresh watchlist';
}
