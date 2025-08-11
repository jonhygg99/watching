import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watching/shared/constants/measures.dart';

class ShowPoster extends StatelessWidget {
  final Map<String, dynamic> show;

  const ShowPoster({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    if (show['images']?['poster'] is! List ||
        (show['images']!['poster'] as List).isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: kShowBorderRadius,
      child: CachedNetworkImage(
        imageUrl: 'https://${(show['images']!['poster'] as List).first}',
        width: kMyShowItemWidth,
        height: kMyShowImageHeight,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(borderRadius: kShowBorderRadius),
      width: kMyShowItemWidth,
      height: kMyShowImageHeight,
      color: Colors.grey[800],
      child: const Icon(Icons.tv, size: 30, color: Colors.white30),
    );
  }
}
