import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/theme/theme_provider.dart';

class NewHeader extends HookWidget {
  final Map<String, dynamic> show;
  final String title;
  final ScrollController? scrollController;

  const NewHeader({
    super.key,
    required this.show,
    required this.title,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Track scroll offset for zoom effect
    final scrollController =
        this.scrollController ?? PrimaryScrollController.of(context);
    final scrollOffset = useState(0.0);

    // Update scroll offset when scrolling
    useEffect(() {
      if (scrollController.hasClients) {
        void onScroll() {
          final offset = scrollController.offset;
          // Only update if the value changes significantly to avoid unnecessary rebuilds
          if ((offset - scrollOffset.value).abs() > 0.5) {
            scrollOffset.value = offset;
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      }
      return null;
    }, [scrollController]);

    // Calculate scale factor based on scroll position (1.0 to 1.2)
    final scale = 1.0 + (scrollOffset.value * 0.0005).clamp(0.0, 0.2);

    final images = show['images'] as Map<String, dynamic>? ?? {};
    final fanartUrl =
        images['fanart'] != null && (images['fanart'] as List).isNotEmpty
            ? 'https://${(images['fanart'] as List).first}'
            : null;

    if (fanartUrl == null) {
      return _buildFallbackHeader(context);
    }

    // Calculate 40% of screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final fanartHeight = screenHeight * 0.65;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return SizedBox(
      width: double.infinity,
      height: fanartHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with zoom effect
          ClipRect(
            child: OverflowBox(
              maxHeight: fanartHeight * 1.2, // Allow for 20% overflow
              alignment: Alignment.topCenter,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: CachedNetworkImage(
                  imageUrl: fanartUrl,
                  width: double.infinity,
                  height: fanartHeight,
                  fit: BoxFit.cover,
                  placeholder:
                      (ctx, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (ctx, url, error) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
          ),

          // Gradient overlay
          _getGradientOverlay(fanartHeight),

          // Rating widget (conditionally rendered)
          if (show['rating'] != null)
            Positioned(
              top: topPadding,
              right: 16,
              child: _getRatingWidget(context),
            ),

          // Title and genres at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: fanartHeight * 0.05, // Positioned above the bottom 20%
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getTitle(context, title),
                const SizedBox(height: 8),
                _getGenresChips(show),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTitle(BuildContext context, String title) {
    final year = show['year']?.toString() ?? '';
    final runtime = show['runtime']?.toString() ?? '';
    final status = show['status']?.toString() ?? '';

    final List<String> infoItems = [
      if (year.isNotEmpty) year,
      if (runtime.isNotEmpty) '$runtime min',
      if (status.isNotEmpty) status,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (infoItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < infoItems.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '•',
                        style: TextStyle(color: Colors.white70, fontSize: 24),
                      ),
                    ),
                  Text(
                    infoItems[i],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4.0,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate text scale factor based on title length
            final titleLength = title.length;
            double fontSize = 48.0;

            // Adjust font size based on title length
            if (titleLength > 30) {
              fontSize = 36.0;
            } else if (titleLength > 25) {
              fontSize = 42.0;
            }

            return Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.1, // Tighter line height for better appearance
                shadows: const [
                  Shadow(
                    offset: Offset(1, 2),
                    blurRadius: 4.0,
                    color: Colors.black,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ],
    );
  }

  Widget _getRatingWidget(BuildContext context) {
    final rating = show['rating']?.toDouble() ?? 0.0;
    if (rating <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6, right: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4.0,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getGradientOverlay(double fanartHeight) {
    return Positioned.fill(
      child: Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeProvider);
          final isDarkMode =
              themeMode == AppThemeMode.dark ||
              (themeMode == AppThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkMode
                        ? [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                          scaffoldDarkBackgroundColor,
                        ]
                        : [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.6),
                          const Color(0xFFF5F5F5),
                        ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getGenresChips(Map<String, dynamic> show) {
    if (show['genres'] == null || (show['genres'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children:
          (show['genres'] as List).map<Widget>((genre) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
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
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  (genre as String).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                  strutStyle: const StrutStyle(
                    fontSize: 12,
                    height: 1.2,
                    leading: 0,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFallbackHeader(BuildContext context) {
    // Use a smaller height for the fallback header
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.4;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          // Gradient overlay
          _getGradientOverlay(headerHeight),

          // Rating widget (conditionally rendered)
          if (show['rating'] != null)
            Positioned(
              top: topPadding,
              right: 16,
              child: _getRatingWidget(context),
            ),

          // Title and genres positioned at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getTitle(context, title),
                const SizedBox(height: 8),
                _getGenresChips(show),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
