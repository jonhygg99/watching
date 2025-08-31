import 'package:flutter/material.dart';
import 'package:watching/shared/constants/colors.dart';

class TinyProgressBar extends StatelessWidget {
  final double percent;
  final int watched;
  final int total;
  final bool showText;

  const TinyProgressBar({
    super.key,
    required this.percent,
    required this.watched,
    required this.total,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF3E3D39)
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          Theme.of(context).brightness == Brightness.dark
                              ? [kGradientLightColor, kGradientDarkColor]
                              : [
                                kGradientLightColorLight,
                                kGradientDarkColorLight,
                              ],
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
      ],
    );
  }
}
