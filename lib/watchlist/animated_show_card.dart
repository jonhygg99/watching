import 'package:flutter/material.dart';
import 'package:watching/watchlist/progress_bar.dart';

/// AnimatedShowCard animates the progress bar to full, then animates the card out (slide up and fade out) when fully watched.
class AnimatedShowCard extends StatefulWidget {
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
  State<AnimatedShowCard> createState() => _AnimatedShowCardState();
}

class _AnimatedShowCardState extends State<AnimatedShowCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.progressDuration,
    );
    _cardController = AnimationController(
      vsync: this,
      duration: widget.cardDuration,
    );
    _progressAnim = Tween<double>(
      begin:
          widget.total > 0
              ? (widget.watched / widget.total).clamp(0.0, 1.0)
              : 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _fadeAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.watched == widget.total && widget.total > 0) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() async {
    if (_animating) return;
    setState(() => _animating = true);
    await _progressController.forward();
    await _cardController.forward();
    widget.onFullyWatched();
  }

  @override
  void didUpdateWidget(covariant AnimatedShowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_animating && widget.watched == widget.total && widget.total > 0) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _cardController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: widget.builder(
              context,
              widget.infoWidget,
            ),
          ),
        );
      },
    );
  }
}
