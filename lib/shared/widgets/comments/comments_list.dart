import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/comments/widgets/tile.dart';
import 'package:watching/shared/widgets/comments/widgets/controller.dart';
import 'package:watching/shared/widgets/comments/widgets/error_widget.dart';
import 'package:watching/shared/widgets/comments/widgets/loading_widget.dart';
import 'package:watching/shared/widgets/comments/widgets/sort_selector.dart';

class CommentsSliver extends HookConsumerWidget {
  const CommentsSliver({
    super.key,
    required this.showId,
    required this.sortKeys,
    this.seasonNumber,
    this.episodeNumber,
    this.scrollController,
  });

  final String showId;
  final List<String> sortKeys;
  final int? seasonNumber;
  final int? episodeNumber;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = useState('likes');

    return _CommentsSliverList(
      sort: sort,
      sortKeys: sortKeys,
      showId: showId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      scrollController: scrollController,
    );
  }
}

class _CommentsSliverList extends ConsumerStatefulWidget {
  const _CommentsSliverList({
    required this.sort,
    required this.sortKeys,
    required this.showId,
    this.seasonNumber,
    this.episodeNumber,
    this.scrollController,
  });

  final ValueNotifier<String> sort;
  final List<String> sortKeys;
  final String showId;
  final int? seasonNumber;
  final int? episodeNumber;
  final ScrollController? scrollController;

  @override
  ConsumerState<_CommentsSliverList> createState() =>
      _CommentsSliverListState();
}

class _CommentsSliverListState extends ConsumerState<_CommentsSliverList> {
  late final CommentsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CommentsController(
      context: context,
      ref: ref,
      showId: widget.showId,
      sortValue: widget.sort.value,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
      scrollController: widget.scrollController,
    );

    widget.sort.addListener(_onSortChanged);
  }

  @override
  void dispose() {
    widget.sort.removeListener(_onSortChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSortChanged() {
    _controller.sortValue = widget.sort.value;
    _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isShowDetails =
        widget.episodeNumber == null && widget.seasonNumber == null;
    return StreamBuilder<CommentsState>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state == null || state.isInitialLoading) {
          return const SliverToBoxAdapter(child: CommentsLoadingWidget());
        }

        if (state.errorMessage != null) {
          return SliverToBoxAdapter(
            child: CommentsErrorWidget(
              message: state.errorMessage!,
              onRetry: _controller.refresh,
            ),
          );
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: kSpacePhoneHorizontal,
                  right: kSpacePhoneHorizontal,
                  top: kSpaceBtwWidgets,
                  bottom: kSpaceBtwTitleWidget,
                ),
                child:
                    isShowDetails
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isShowDetails)
                              Text(
                                AppLocalizations.of(context)!.comments,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            CommentsSortSelector(
                              value: widget.sort.value,
                              sortKeys: widget.sortKeys,
                              isShowDetails: isShowDetails,
                              onChanged: (value) {
                                if (value != null) {
                                  widget.sort.value = value;
                                }
                              },
                            ),
                          ],
                        )
                        : CommentsSortSelector(
                          value: widget.sort.value,
                          sortKeys: widget.sortKeys,
                          isShowDetails: isShowDetails,
                          onChanged: (value) {
                            if (value != null) {
                              widget.sort.value = value;
                            }
                          },
                        ),
              ),
            ),
            if (state.comments.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            else
              _buildCommentsList(state),
            if (state.hasMore)
              SliverToBoxAdapter(
                child:
                    _controller.isLoadingMore
                        ? const CommentsLoadingWidget(isInitialLoad: false)
                        : const SizedBox.shrink(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsList(CommentsState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return CommentTile(comment: state.comments[index]);
      }, childCount: state.comments.length),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.noCommentsYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet with all comments for a show or episode
///
/// [showId] - The ID of the show
/// [sort] - The current sort value
/// [sortKeys] - Map of sort values to display names
/// [ref] - The WidgetRef for Riverpod
/// [seasonNumber] - Optional season number for episode comments
/// [episodeNumber] - Optional episode number for episode comments
Future<void> showAllComments(
  BuildContext context,
  String string, {
  required String showId,
  required ValueNotifier<String> sort,
  required List<String> sortKeys,
  required WidgetRef ref,
  int? seasonNumber,
  int? episodeNumber,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
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
    },
  );
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
