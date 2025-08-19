import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/shared/utils/get_image.dart';
import 'package:watching/show_details/widgets/header/widgets/rating.dart';
import 'package:watching/show_details/widgets/header/widgets/gradient_overlay.dart';
import 'package:watching/show_details/widgets/header/widgets/genres_chips.dart';
import 'package:watching/show_details/widgets/header/widgets/info_items_row.dart';
import 'package:watching/show_details/widgets/header/widgets/title.dart';
import 'package:watching/show_details/widgets/header/widgets/fanart_image.dart';

class Header extends HookWidget {
  final Map<String, dynamic> show;
  final String title;
  final ScrollController? scrollController;

  const Header({
    super.key,
    required this.show,
    required this.title,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final rating = show['rating']?.toDouble() ?? 0.0;
    final fanartUrl = getFirstAvailableImage(show['images']);

    if (fanartUrl == null) {
      return _buildFallbackHeader(context);
    }

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
          FanartImage(imageUrl: fanartUrl, height: fanartHeight, scale: scale),
          GradientOverlay(),
          Positioned(top: topPadding, right: 16, child: Rating(rating: rating)),
          Positioned(
            left: 16,
            right: 16,
            bottom: fanartHeight * 0.05, // Positioned above the bottom 20%
            child: _buildHeaderContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InfoItemsRow(
          items: [
            if (show['year'] != null) show['year'].toString(),
            if (show['runtime'] != null) '${show['runtime']} min',
            if (show['status'] != null) show['status'].toString(),
          ],
        ),
        TitleWidget(title: title),
        const SizedBox(height: 8),
        GenresChips(genres: show['genres'] as List? ?? []),
      ],
    );
  }

  Widget _buildFallbackHeader(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.3;
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          const GradientOverlay(),
          if (show['rating'] != null)
            Positioned(
              top: topPadding,
              right: 16,
              child: Rating(rating: show['rating']?.toDouble() ?? 0.0),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: headerHeight * 0.05, // Positioned above the bottom 20%
            child: _buildHeaderContent(),
          ),
        ],
      ),
    );
  }
}
