import 'package:flutter/material.dart';
import 'package:watching/shared/widgets/expandable_text.dart';

class ShowDescription extends StatelessWidget {
  final String tagline;
  final String overview;

  const ShowDescription({
    super.key,
    required this.tagline,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tagline.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 8),
            child: Text(
              tagline,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        if (overview.isNotEmpty)
          ExpandableText(
            overview,
            style: const TextStyle(fontSize: 15),
            buttonStyle: const TextStyle(fontSize: 14),
          ),
      ],
    );
  }
}
