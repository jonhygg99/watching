String? _getImageUrl(dynamic imageList) {
  if (imageList is List && imageList.isNotEmpty && imageList.first is String) {
    final url = imageList.first as String;
    if (url.startsWith('http')) return url;
    return 'https://$url';
  }
  return null;
}

String? getFirstAvailableImage(
  Map<String, dynamic>? images, {
  String? preferredType,
}) {
  if (images == null) return null;

  // Try preferred type first if specified
  if (preferredType != null) {
    final preferredUrl = _getImageUrl(images[preferredType]);
    if (preferredUrl != null) return preferredUrl;
  }

  // Fallback to default order of preference
  for (final type in ['poster', 'fanart', 'thumb', 'banner']) {
    // Skip if we already checked this as the preferred type
    if (type == preferredType) continue;

    final url = _getImageUrl(images[type]);
    if (url != null) return url;
  }

  return null;
}

/// Extract screenshot URL from episode data
String? getScreenshotUrl(Map<String, dynamic> episode) {
  // Try the new format first (images object with screenshot array)
  if (episode['images']?['screenshot'] is List &&
      (episode['images']?['screenshot'] as List).isNotEmpty) {
    final screenshot = episode['images']['screenshot'][0];
    if (screenshot is String) {
      return screenshot.startsWith('http') ? screenshot : 'https://$screenshot';
    } else if (screenshot is Map<String, dynamic>) {
      // If it's a map, try to get the full image URL
      return screenshot['full'] ??
          screenshot['medium'] ??
          screenshot['thumb'] ??
          (screenshot.values.isNotEmpty ? screenshot.values.first : null);
    }
  }

  // Fall back to the old format if present
  if (episode['screenshot'] is Map<String, dynamic>) {
    final screenshot = episode['screenshot'] as Map<String, dynamic>;
    return screenshot['full'] ?? screenshot['medium'] ?? screenshot['thumb'];
  }

  return null;
}
