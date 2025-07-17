import 'package:flutter/material.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'package:watching/shared/widgets/comments_list.dart';

/// Shows a modal bottom sheet with all comments for a show
Future<void> showAllComments(
  BuildContext context,
  String showId, {
  String title = 'Comentarios',
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final sortNotifier = ValueNotifier<String>('newest');
      
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) {
          return ValueListenableBuilder<String>(
            valueListenable: sortNotifier,
            builder: (context, sort, _) {
              return Column(
                children: [
                  AppBar(
                    title: Text(title),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          sortNotifier.value = value;
                        },
                        itemBuilder: (context) => commentSortOptions.entries
                            .map((e) => PopupMenuItem<String>(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        icon: const Icon(Icons.sort),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CommentsList(
                      type: CommentType.show,
                      id: showId,
                      sort: sortNotifier,
                      sortLabels: commentSortOptions,
                      showTitle: false,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
