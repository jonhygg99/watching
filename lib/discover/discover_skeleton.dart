import 'package:flutter/material.dart';

/// A skeleton loading widget for discover page carousels that matches the actual UI
class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed dimensions for skeleton items
        const itemWidth = 145.0;
        const imageHeight = 206.0;
        // Calculate carousel height to fit the image and text
        final carouselHeight = imageHeight + 40;

        return SizedBox(
          width: double.infinity,
          height: carouselHeight + 40, // Extra space for the title
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title placeholder - matches the actual title style
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  bottom: 8,
                  right: 16,
                ),
                child: Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Carousel items
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 8,
                  ),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (context, index) => SizedBox(
                        width: itemWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image placeholder - matches the actual image container
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: itemWidth,
                                height: imageHeight,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                              ),
                            ),
                            // Title placeholder - matches the actual title style
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              height: 16,
                              width: itemWidth * 0.7,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
