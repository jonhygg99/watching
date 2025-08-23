import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentTileSkeleton extends StatelessWidget {
  const CommentTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and user info
              Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: highlightColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 120, color: highlightColor),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 80, color: highlightColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    color: highlightColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Like button and action buttons
              Row(
                children: [
                  // Container(height: 16, width: 40, color: highlightColor),
                  const Spacer(),
                  // Container(height: 16, width: 60, color: highlightColor),
                  // const SizedBox(width: 16),
                  Container(height: 16, width: 40, color: highlightColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentsListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentsListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: CommentTileSkeleton(),
        ),
      ),
    );
  }
}
