import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/services/trakt/trakt_api.dart';

class EpisodeComments extends ConsumerStatefulWidget {
  final int showId;
  final int seasonNumber;
  final int episodeNumber;

  const EpisodeComments({
    super.key,
    required this.showId,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  @override
  ConsumerState<EpisodeComments> createState() => _EpisodeCommentsState();
}

class _EpisodeCommentsState extends ConsumerState<EpisodeComments> {
  late final Future<List<Map<String, dynamic>>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    try {
      final traktApi = TraktApi();
      final comments = await traktApi.getEpisodeComments(
        id: widget.showId.toString(),
        season: widget.seasonNumber,
        episode: widget.episodeNumber,
      );
      return List<Map<String, dynamic>>.from(comments);
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading comments: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No comments yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentTile(comment);
          },
        );
      },
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    final user = comment['user'] ?? {};
    final userName = user['username'] ?? 'Unknown';
    final userAvatar = user['images']?['avatar']?['full'];
    final commentText = comment['comment'] ?? '';
    final likes = comment['likes'] ?? 0;
    final isSpoiler = comment['spoiler'] == true;
    final isReview = comment['review'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (userAvatar != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(userAvatar),
                    radius: 20,
                  )
                else
                  const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Text(
                  userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isSpoiler)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SPOILER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isReview) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'REVIEW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(commentText, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.thumb_up, size: 20),
                const SizedBox(width: 6),
                Text(
                  likes.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
