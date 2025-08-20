import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/carousel/app_carousel.dart';
import 'package:watching/shared/widgets/carousel/skeleton/skeleton.dart';
import 'package:watching/shared/widgets/carousel/widgets/carousel_item.dart';

class Carousel extends ConsumerWidget {
  final String title;
  final Future<List<dynamic>>? future;
  final dynamic Function(dynamic) extractShow;
  final String emptyText;
  final VoidCallback? onViewMore;

  const Carousel({
    required this.title,
    required this.future,
    required this.extractShow,
    required this.emptyText,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget now primarily handles the FutureBuilder logic
    // and delegates the UI to AppCarousel.
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DiscoverSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];

        return AppCarousel<dynamic>(
          title: title,
          items: items,
          itemBuilder: (context, showData) {
            return CarouselItem(
              show: extractShow(showData),
              itemWidth: kDiscoverShowItemWidth,
              shows: items,
              index: items.indexOf(showData),
            );
          },
          itemHeight: kDiscoverShowImageHeight + 60, // Adjusted for title
          emptyText: emptyText,
          onViewMore: onViewMore,
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: kVerticalPaddingPhone,
      child: Center(
        child: Text(
          'Error loading data: $error',
          style: const TextStyle(color: kErrorColorMessage),
        ),
      ),
    );
  }
}
