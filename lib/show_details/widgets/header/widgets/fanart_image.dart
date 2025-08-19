import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FanartImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double scale;

  const FanartImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxHeight: height * 1.2, // Allow for 20% overflow
        alignment: Alignment.topCenter,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (ctx, url, error) => const Icon(
              Icons.broken_image,
              size: 80,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
