import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final user = comment['user'] ?? {};
    final userName = user['username'] ?? 'Unknown';
    final userAvatar = user['images']?['avatar']?['full'];
    final commentText = comment['comment'] ?? '';
    final likes = comment['likes'] ?? 0;
    final isSpoiler = comment['spoiler'] == true;
    final isReview = comment['review'] == true;
    final date = comment['created_at']?.substring(0, 10) ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              userAvatar,
              userName,
              date,
              isSpoiler,
              isReview,
            ),
            const SizedBox(height: 8),
            Text(commentText),
            const SizedBox(height: 8),
            _buildFooter(context, likes),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String? userAvatar,
    String userName,
    String date,
    bool isSpoiler,
    bool isReview,
  ) {
    return Row(
      children: [
        if (userAvatar != null)
          CircleAvatar(backgroundImage: NetworkImage(userAvatar), radius: 20)
        else
          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (isSpoiler)
          _buildBadge(
            context,
            AppLocalizations.of(context)!.spoiler,
            Colors.red,
          ),
        if (isReview) ...[
          const SizedBox(width: 8),
          _buildBadge(
            context,
            AppLocalizations.of(context)!.review,
            Colors.blue,
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int likes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.thumb_up_outlined, size: 20),
        const SizedBox(width: 6),
        Text(
          likes.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
