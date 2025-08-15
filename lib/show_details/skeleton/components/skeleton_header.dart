import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonHeader extends StatelessWidget {
  const SkeletonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final fanartHeight = size.height * 0.65;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: SizedBox(
          height: fanartHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dark overlay for better text visibility
              Container(color: Colors.black.withValues(alpha: 0.4)),

              // Rating skeleton
              Positioned(
                top: topPadding,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ), // 10px padding on all sides
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                    ), // 6px horizontal padding
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 20),
                        const SizedBox(width: 4),
                        Container(
                          width:
                              24, // Adjusted to match typical rating text width
                          height: 20, // Matches text height
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title and genres positioned at the bottom
              Positioned(
                left: 16,
                right: 16,
                bottom: 16, // Fixed bottom margin to match actual header
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Info row (year, runtime, status)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Year chip (e.g., 2022) - narrower width
                        _buildInfoChip(context, width: 48.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        // Runtime chip (e.g., 42 min) - medium width
                        _buildInfoChip(context, width: 70.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        // Status chip (e.g., Returning Series) - wider width
                        _buildInfoChip(context, width: 100.0),
                      ],
                    ),
                    // Title
                    Container(
                      width: size.width * 0.5,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Genres
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildGenreChip(context),
                        _buildGenreChip(context),
                        _buildGenreChip(context),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {double width = 60.0}) {
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildGenreChip(BuildContext context) {
    return Container(
      width: 80, // Fixed width for all chips
      height: 28, // Fixed height for all chips
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }
}
