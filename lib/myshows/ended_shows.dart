import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/myshows/base_shows_list.dart';

class EndedShows extends BaseShowsList {
  const EndedShows({super.key}) : super(title: 'Ended Shows');

  @override
  ConsumerState<BaseShowsList> createState() => _EndedShowsState();

  @override
  bool shouldIncludeShow(Map<String, dynamic> showData) {
    final status = (showData['status'] ?? '').toString().toLowerCase();
    return status == 'ended' || status == 'canceled';
  }
}

class _EndedShowsState extends BaseShowsListState<EndedShows> {}
