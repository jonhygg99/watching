import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'add_to_watch_history_test.dart' as add_to_watch_history;
import 'remove_from_history_test.dart' as remove_from_history;
import 'get_watched_test.dart' as get_watched;
import 'get_watchlist_test.dart' as get_watchlist;

void main() {
  group('History API Tests', () {
    // Run all test groups from each file
    add_to_watch_history.main();
    remove_from_history.main();
    get_watched.main();
    get_watchlist.main();
  });
}
