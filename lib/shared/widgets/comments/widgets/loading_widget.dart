import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'package:watching/shared/widgets/comments/widgets/comment_tile_skeleton.dart';
import 'package:watching/shared/widgets/comments/widgets/sort_selector.dart';

class CommentsLoadingWidget extends StatefulWidget {
  final bool isInitialLoad;
  final String currentSort;
  final ValueChanged<String>? onSortChanged;
  final bool showSortSelector;
  final bool isShowDetails;

  const CommentsLoadingWidget({
    super.key,
    this.isInitialLoad = true,
    this.currentSort = 'likes',
    this.onSortChanged,
    this.showSortSelector = true,
    this.isShowDetails = true,
  });

  @override
  State<CommentsLoadingWidget> createState() => _CommentsLoadingWidgetState();
}

class _CommentsLoadingWidgetState extends State<CommentsLoadingWidget> {
  late String _currentSort;

  @override
  void initState() {
    super.initState();
    _currentSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.only(
        top: kSpaceBtwWidgets,
        bottom: kSpaceBtwTitleWidget,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSortSelector) ..._buildSortSelector(context),
          const SizedBox(height: 16),
          const CommentsListSkeleton(itemCount: 6),
        ],
      ),
    );

    if (widget.isInitialLoad) {
      return content;
    }

    return content;
  }

  List<Widget> _buildSortSelector(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacePhoneHorizontal),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isShowDetails
                  ? AppLocalizations.of(context)!.comments
                  : AppLocalizations.of(context)!.filters,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            CommentsSortSelector(
              value: _currentSort,
              sortKeys: commentSortOptions.keys.toList(),
              isShowDetails: true,
              onChanged: (value) {
                if (value != null && value != _currentSort) {
                  setState(() {
                    _currentSort = value;
                  });
                  widget.onSortChanged?.call(value);
                }
              },
            ),
          ],
        ),
      ),
    ];
  }
}
