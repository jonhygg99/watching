import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';

class EpisodeInfoModal extends StatefulWidget {
  final Future<Map<String, dynamic>> episodeFuture;
  final String showId;
  final int seasonNumber;
  final int episodeNumber;

  const EpisodeInfoModal({
    super.key,
    required this.episodeFuture,
    required this.showId,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  @override
  State<EpisodeInfoModal> createState() => _EpisodeInfoModalState();
}

class _EpisodeInfoModalState extends State<EpisodeInfoModal> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.episodeFuture,
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          content = Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final ep = snapshot.data;
          if (ep == null) {
            content = const SizedBox.shrink();
          } else {
            final img =
                (ep['images']?['screenshot'] is List &&
                        ep['images']['screenshot'].isNotEmpty)
                    ? ep['images']['screenshot'][0]
                    : null;
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ep['title'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'T${ep['season']}E${ep['number']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (img != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl:
                          (img is String && !img.startsWith('http'))
                              ? 'https://$img'
                              : img,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                if (ep['overview'] != null &&
                    ep['overview'].toString().isNotEmpty)
                  Text(
                    ep['overview'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (ep['rating'] != null) ...[
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${ep['rating']?.toStringAsFixed(1) ?? ''}'),
                      const SizedBox(width: 16),
                    ],
                    if (ep['runtime'] != null) ...[
                      const Icon(Icons.timer, size: 18),
                      const SizedBox(width: 4),
                      Text('${ep['runtime']} min'),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Comments button (aligned left)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Función de comentarios próximamente',
                            ),
                          ),
                        );
                      },
                      child: const Text('Comentarios'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),

                    // Spacer to push the watched button to the right
                    const Spacer(),

                    // Watched toggle button (aligned right)
                    Consumer(
                      builder: (context, ref, _) {
                        final isWatched = ep['watched'] == true;
                        final isWatching = ref.watch(
                          watchlistProvider.select((state) => state.isLoading),
                        );

                        return TextButton(
                          onPressed:
                              isWatching
                                  ? null
                                  : () async {
                                    final notifier = ref.read(
                                      watchlistProvider.notifier,
                                    );
                                    final showId = widget.showId;
                                    final seasonNumber = widget.seasonNumber;
                                    final episodeNumber = widget.episodeNumber;
                                    final newWatchedState = !isWatched;

                                    try {
                                      await notifier.toggleEpisodeWatchedStatus(
                                        showTraktId: showId,
                                        seasonNumber: seasonNumber,
                                        episodeNumber: episodeNumber,
                                        watched: newWatchedState,
                                      );

                                      // Actualizar el estado local
                                      if (mounted) {
                                        setState(() {
                                          ep['watched'] = newWatchedState;
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error al actualizar el estado del episodio',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                          child:
                              isWatching
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isWatched
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 18,
                                        color:
                                            isWatched
                                                ? Colors.green[700]
                                                : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isWatched ? 'Visto' : 'No visto',
                                        style: TextStyle(
                                          color:
                                              isWatched
                                                  ? Colors.green[700]
                                                  : null,
                                          fontWeight:
                                              isWatched
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            backgroundColor:
                                isWatched
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          }
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: content),
        );
      },
    );
  }
}
