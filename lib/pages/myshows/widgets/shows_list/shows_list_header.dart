import 'package:flutter/material.dart';

class ShowsListHeader extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool isLoading;
  final bool isRefreshing;

  const ShowsListHeader({
    super.key,
    required this.title,
    required this.itemCount,
    this.isLoading = false,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ($itemCount)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (isLoading || isRefreshing) const SizedBox(height: 8),
          if (isLoading || isRefreshing) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
