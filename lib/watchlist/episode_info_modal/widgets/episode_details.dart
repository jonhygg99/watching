import 'package:flutter/material.dart';
import 'package:watching/shared/widgets/expandable_text.dart';

class EpisodeDetails extends StatelessWidget {
  final Map<String, dynamic> episode;

  const EpisodeDetails({
    super.key,
    required this.episode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (episode['overview'] != null &&
            episode['overview'].toString().isNotEmpty)
          ExpandableText(
            episode['overview'],
            style: Theme.of(context).textTheme.bodyMedium,
            buttonStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (episode['rating'] != null) ...[
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(episode['rating']?.toStringAsFixed(1) ?? ''),
              const SizedBox(width: 16),
            ],
            if (episode['runtime'] != null) ...[
              const Icon(Icons.timer, size: 18),
              const SizedBox(width: 4),
              Text('${episode['runtime']} min'),
            ],
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
