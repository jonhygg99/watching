import 'package:flutter/material.dart';

class VideoInfo extends StatelessWidget {
  const VideoInfo({
    super.key,
    required this.title,
    this.type,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
  });

  final String? title;
  final String? type;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          if (type != null) ...[
            const SizedBox(height: 2),
            Text(
              type!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
