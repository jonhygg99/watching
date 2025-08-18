import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CarouselImageItem extends StatelessWidget {
  const CarouselImageItem({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  final String? imageUrl;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Stack(
                children: [
                  Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              ),
          errorWidget:
              (context, url, error) => const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
        ),
      ),
    );
  }
}
