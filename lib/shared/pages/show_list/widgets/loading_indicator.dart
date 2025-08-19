import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.height = 60,
    this.indicatorSize = 24,
    this.strokeWidth = 2,
    this.alpha = 0.8,
  });

  final double height;
  final double indicatorSize;
  final double strokeWidth;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: height,
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(alpha),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
