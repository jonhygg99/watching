import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../skeleton_utils.dart';
import 'package:watching/shared/constants/colors.dart';

class SkeletonEpisode extends StatelessWidget {
  const SkeletonEpisode({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Episode title and number
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Season and episode number (e.g., T1:E1)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: SkeletonContainer(
                          height: 20,
                          width: 50,
                          radius: 4,
                        ),
                      ),
                      // Episode title
                      Expanded(
                        child: SkeletonContainer(
                          height: 20,
                          width: double.infinity,
                          radius: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Watched counter (e.g., 5/10)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SkeletonContainer(
                    height: 16,
                    width: 40,
                    radius: 6,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Stack(
                children: [
                  // Background of progress bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progress indicator (60% filled)
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [gradientLightColor, gradientDarkColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buttons row
            Row(
              children: [
                // Check All Episodes button (gradient blue)
                Expanded(
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gradientLightColor, gradientDarkColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Check Out All Episodes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Episode Info button (gradient gold)
                Expanded(
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD6C498), Color(0xFF966D39)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Episode Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
