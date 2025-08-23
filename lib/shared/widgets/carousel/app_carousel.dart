import 'package:flutter/material.dart';
import 'package:watching/shared/widgets/carousel/widgets/carousel_header.dart';
import 'package:watching/shared/constants/measures.dart';

class AppCarousel<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback? onViewMore;
  final double itemHeight;
  final String emptyText;

  const AppCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.onViewMore,
    required this.itemHeight,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselHeader(title: title, onViewMore: onViewMore),
        SizedBox(
          height: itemHeight,
          child: items.isEmpty
              ? Center(child: Text(emptyText))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: kSpacePhoneHorizontal),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: kSpaceCarousel),
                      child: itemBuilder(context, item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
