String? _getImageUrl(dynamic imageList) {
  if (imageList is List && imageList.isNotEmpty && imageList.first is String) {
    final url = imageList.first as String;
    if (url.startsWith('http')) return url;
    return 'https://$url';
  }
  return null;
}

String? getFirstAvailableImage(Map<String, dynamic>? images) {
  if (images == null) return null;

  // Try different image types in order of preference
  for (final type in ['poster', 'thumb', 'fanart', 'banner']) {
    final url = _getImageUrl(images[type]);
    if (url != null) return url;
  }
  return null;
}
