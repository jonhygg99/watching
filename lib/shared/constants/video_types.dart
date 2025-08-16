/// Constants for different types of videos in the app
class VideoTypes {
  static const String trailer = 'trailer';
  static const String teaser = 'teaser';
  static const String clip = 'clip';
  static const String featurette = 'featurette';
  
  /// Returns a list of all valid video types
  static List<String> get all => [trailer, teaser, clip, featurette];
  
  /// Validates if the given type is a valid video type
  static bool isValid(String type) => all.contains(type);
}
