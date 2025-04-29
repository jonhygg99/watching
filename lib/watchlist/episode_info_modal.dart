import 'package:flutter/material.dart';

class EpisodeInfoModal extends StatelessWidget {
  final Future<Map<String, dynamic>> episodeFuture;
  const EpisodeInfoModal({Key? key, required this.episodeFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: episodeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: [36m${snapshot.error}[0m'));
        }
        final ep = snapshot.data;
        if (ep == null) return const SizedBox.shrink();
        final img = (ep['images']?['screenshot'] is List && ep['images']['screenshot'].isNotEmpty)
            ? ep['images']['screenshot'][0]
            : null;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ep['title'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('T${ep['season']}E${ep['number']}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                if (img != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      (img is String && !img.startsWith('http')) ? 'https://$img' : img,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                if (ep['overview'] != null && ep['overview'].toString().isNotEmpty)
                  Text(ep['overview'], style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (ep['rating'] != null) ...[
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('${ep['rating']?.toStringAsFixed(1) ?? ''}'),
                      SizedBox(width: 16),
                    ],
                    if (ep['runtime'] != null) ...[
                      const Icon(Icons.timer, size: 18),
                      SizedBox(width: 4),
                      Text('${ep['runtime']} min'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
