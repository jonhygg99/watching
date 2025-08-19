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
