import 'package:flutter/material.dart';
import 'details_page.dart';

class RelatedShowCard extends StatelessWidget {
  final Map<String, dynamic> showData;
  final double width;
  final double height;
  final double imageHeight;
  final double borderRadius;
  final double spacing;

  const RelatedShowCard({
    super.key,
    required this.showData,
    this.width = 160,
    this.height = 240,
    this.imageHeight = 200,
    this.borderRadius = 12,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic posterData = showData['images']?['poster'];
    final String? img = (posterData is List && posterData.isNotEmpty)
        ? posterData[0]?.toString()
        : null;

    return GestureDetector(
      onTap: () {
        final relatedId = showData['ids']?['slug'] ??
            showData['ids']?['trakt']?.toString() ??
            showData['ids']?['imdb'] ??
            '';
        if (relatedId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowDetailPage(showId: relatedId),
            ),
          );
        }
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: img != null
                  ? Image.network(
                      img.startsWith('http') ? img : 'https://$img',
                      height: imageHeight,
                      width: width,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            SizedBox(height: spacing),
            Text(
              showData['title'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: imageHeight,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}
