import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/myshows/base_shows_list.dart';

class WaitingShows extends BaseShowsList {
  const WaitingShows({super.key}) : super(title: 'Upcoming Shows');

  @override
  ConsumerState<BaseShowsList> createState() => _WaitingShowsState();

  @override
  bool shouldIncludeShow(Map<String, dynamic> showData) {
    final status = (showData['status'] ?? '').toString().toLowerCase();
    // Include shows that are not ended or canceled
    return status != 'ended' && status != 'canceled';
  }
}

class _WaitingShowsState extends BaseShowsListState<WaitingShows> {}
