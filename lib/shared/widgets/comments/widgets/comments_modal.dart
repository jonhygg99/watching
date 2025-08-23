import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/widgets/comments/comments_list.dart';

/// Shows a modal bottom sheet with all comments for a show or episode
class CommentsModal extends StatelessWidget {
  const CommentsModal({
    super.key,
    required this.showId,
    required this.sort,
    required this.sortKeys,
    required this.ref,
    this.seasonNumber,
    this.episodeNumber,
  });

  final String showId;
  final ValueNotifier<String> sort;
  final List<String> sortKeys;
  final WidgetRef ref;
  final int? seasonNumber;
  final int? episodeNumber;

  /// Shows the comments modal
  static Future<void> show(
    BuildContext context, {
    required String showId,
    required ValueNotifier<String> sort,
    required List<String> sortKeys,
    required WidgetRef ref,
    int? seasonNumber,
    int? episodeNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentsModal(
        showId: showId,
        sort: sort,
        sortKeys: sortKeys,
        ref: ref,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        color: Theme.of(context).colorScheme.surface,
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: kToolbarHeight,
              elevation: 0,
              title: _CommentsHeader(
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
            ),
            CommentsSliver(
              showId: showId,
              sortKeys: sortKeys,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
              scrollController: scrollController,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _CommentsHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.comments,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}
