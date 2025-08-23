import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;

  const TitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
    );
  }
}
