import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/shared/constants/measures.dart';

class CarouselImageItem extends StatelessWidget {
  const CarouselImageItem({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.width,
    this.height = kDiscoverShowImageHeight,
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 32,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
