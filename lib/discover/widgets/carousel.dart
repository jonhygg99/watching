import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/discover/widgets/skeleton.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';

import 'carousel/carousel_item.dart';
import 'carousel/carousel_header.dart';

/// A widget that displays a carousel of shows with a title and view more option.
class Carousel extends ConsumerWidget {
  /// Creates a carousel that fetches and displays shows
  const Carousel({
    super.key,
    required this.title,
    required this.future,
    required this.extractShow,
    required this.emptyText,
    required this.onViewMore,
  }) : shows = const [];

  /// Creates a carousel that displays a static list of shows
  const Carousel.static({
    super.key,
    required this.title,
    required this.shows,
    required this.extractShow,
    required this.emptyText,
    this.onViewMore,
  }) : future = null;

  final String title;
  final Future<List<dynamic>>? future;
  final List<dynamic> shows;
  final dynamic Function(dynamic) extractShow;
  final String emptyText;
  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (future != null) {
      return FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DiscoverSkeleton();
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          return _buildCarousel(snapshot.data ?? [], ref);
        },
      );
    }

    // For static carousel
    return _buildCarousel(shows, ref);
  }

  Widget _buildCarousel(List<dynamic> items, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselHeader(title: title, onViewMore: onViewMore),
        LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = kDiscoverShowImageHeight + 40;
            if (items.isEmpty) {
              return SizedBox(
                height: carouselHeight,
                child: Center(child: Text(emptyText)),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: kSpacePhoneHorizontal),
              child: Row(
                children:
                    items.map((showData) {
                      return Padding(
                        padding: const EdgeInsets.only(right: kSpaceCarousel),
                        child: CarouselItem(
                          ref: ref,
                          context: context,
                          show: extractShow(showData),
                          itemWidth: kDiscoverShowItemWidth,
                          shows: items,
                          index: items.indexOf(showData),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ],
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
