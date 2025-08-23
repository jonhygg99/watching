class VideoUtils {
  static String? extractYoutubeVideoId(String? url) {
    if (url == null) return null;
    
    final regExp = RegExp(
      r'(?:v=|youtu\.be/|embed/)([\w-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  static String? getYoutubeThumbnailUrl(String? videoId) {
    return videoId != null 
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;
  }
}
