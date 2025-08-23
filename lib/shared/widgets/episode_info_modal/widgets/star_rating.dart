import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatefulWidget {
  final double? initialRating;
  final double size;
  final ValueChanged<double?> onRatingChanged;

  const StarRating({
    super.key,
    this.initialRating = 0.0,
    this.size = 20.0,
    required this.onRatingChanged,
  });

  @override
  StarRatingState createState() => StarRatingState();
}

class StarRatingState extends State<StarRating> {
  late double _currentRating;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating ?? 0.0;
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      _currentRating = widget.initialRating ?? 0.0;
    }
  }

  void _handleRatingUpdate(double newRating) {
    final now = DateTime.now();
    bool isDoubleTap = false;

    // Check if this is a double tap (within 300ms) on the same star value
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300) &&
        _currentRating == newRating) {
      isDoubleTap = true;
    }

    setState(() {
      if (isDoubleTap) {
        _currentRating = 0.0;
      } else {
        _currentRating = newRating > 0 ? newRating : _currentRating;
      }
      _lastTapTime = now;
    });

    // If it's a double tap, remove the rating (pass null)
    // Otherwise, update the rating if it's greater than 0
    if (isDoubleTap) {
      widget.onRatingChanged(null);
    } else if (newRating > 0) {
      widget.onRatingChanged(newRating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _currentRating,
      minRating: 0,
      maxRating: 5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: widget.size,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, index) {
        return const Icon(Icons.star, color: Colors.amber);
      },
      onRatingUpdate: _handleRatingUpdate,
      updateOnDrag: true,
      glow: false,
    );
  }
}
