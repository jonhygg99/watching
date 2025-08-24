import 'package:flutter/material.dart';

class SkeletonContainer extends StatelessWidget {
  final double height;
  final double width;
  final bool isCircle;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkeletonContainer({
    super.key,
    required this.height,
    required this.width,
    this.isCircle = false,
    this.radius = 4.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

class SkeletonSpacer extends StatelessWidget {
  final double height;

  const SkeletonSpacer({super.key, this.height = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
