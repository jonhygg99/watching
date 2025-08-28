/// Represents the current state of an episode in the UI
enum EpisodeState {
  /// Episode is not watched
  unwatched,
  
  /// Episode is currently being processed (marked as watched/unwatched)
  processing,
  
  /// Episode is watched
  watched,
}

extension EpisodeStateX on EpisodeState {
  /// Returns true if the episode is in the processing state
  bool get isProcessing => this == EpisodeState.processing;
  
  /// Returns true if the episode is in the watched state
  bool get isWatched => this == EpisodeState.watched;
  
  /// Returns true if the episode is in the unwatched state
  bool get isUnwatched => this == EpisodeState.unwatched;
}
