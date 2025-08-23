import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/progress_bar.dart';

/// AnimatedShowCard animates the progress bar to full, then animates the card out (slide up and fade out) when fully watched.
class AnimatedShowCard extends HookWidget {
  final String? traktId;
  final String? posterUrl;
  final int watched;
  final int total;
  final Widget infoWidget;
  final VoidCallback onFullyWatched;
  final Duration progressDuration;
  final Duration cardDuration;
  final Widget Function(BuildContext, Widget) builder;

  const AnimatedShowCard({
    super.key,
    required this.traktId,
    required this.posterUrl,
    required this.watched,
    required this.total,
    required this.infoWidget,
    required this.onFullyWatched,
    required this.builder,
    this.progressDuration = const Duration(milliseconds: 600),
    this.cardDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final progressController = useAnimationController(
      duration: progressDuration,
    );
    final cardController = useAnimationController(duration: cardDuration);
    final animating = useState(false);

    final progressAnim = useMemoized(
      () => Tween<double>(
        begin: total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: progressController, curve: Curves.easeInOut),
      ),
      [total, watched],
    );

    final slideAnim = useMemoized(
      () => Tween<double>(begin: 0, end: -60).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeInOut),
      ),
      [],
    );

    final fadeAnim = useMemoized(
      () => Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeInOut),
      ),
      [],
    );

    Future<void> startAnimation() async {
      if (animating.value) return;
      animating.value = true;
      await progressController.forward();
      await cardController.forward();
      onFullyWatched();
    }

    // Handle initial animation check
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (watched == total && total > 0) {
          startAnimation();
        }
      });
      return null;
    }, []);

    // Handle updates
    useEffect(() {
      if (!animating.value && watched == total && total > 0) {
        startAnimation();
      }
      return null;
    }, [watched, total, animating.value]);

    return AnimatedBuilder(
      animation: Listenable.merge([progressController, cardController]),
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, slideAnim.value),
            child: builder(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoWidget,
                  const SizedBox(height: kSpaceBtwTitleWidget),
                  ProgressBar(
                    percent: progressAnim.value,
                    watched: total,
                    total: total,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
