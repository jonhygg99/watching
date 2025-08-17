import 'package:flutter/material.dart';
import 'package:watching/discover/discover_skeleton.dart';
import 'package:watching/discover/show_carousel.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';

/// A widget that displays a carousel of shows with a title and view more option.
class DiscoverCarousel extends StatelessWidget {
  const DiscoverCarousel({
    super.key,
    required this.title,
    required this.future,
    required this.extractShow,
    required this.emptyText,
    required this.onViewMore,
  });

  final String title;
  final Future<List<dynamic>> future;
  final Map<String, dynamic> Function(dynamic) extractShow;
  final String emptyText;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const DiscoverSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        return ShowCarousel(
          title: title,
          shows: snapshot.data ?? [],
          extractShow: extractShow,
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
