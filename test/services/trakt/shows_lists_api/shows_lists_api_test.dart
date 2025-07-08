import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'get_trending_shows_test.dart' as trending_shows;
import 'get_most_played_shows_test.dart' as most_played_shows;
import 'get_most_collected_shows_test.dart' as most_collected_shows;
import 'get_popular_shows_test.dart' as popular_shows;
import 'get_most_favorited_shows_test.dart' as most_favorited_shows;
import 'get_most_watched_shows_test.dart' as most_watched_shows;
import 'get_most_anticipated_shows_test.dart' as most_anticipated_shows;

void main() {
  group('Shows Lists API Tests', () {
    // Run all test groups from each file
    trending_shows.main();
    most_played_shows.main();
    most_collected_shows.main();
    popular_shows.main();
    most_favorited_shows.main();
    most_watched_shows.main();
    most_anticipated_shows.main();
  });
}
