import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'get_episode_info_test.dart' as episode_info;
import 'get_related_shows_test.dart' as related_shows;
import 'get_season_episodes_test.dart' as season_episodes;
import 'get_seasons_test.dart' as seasons;
import 'get_show_by_id_test.dart' as show_by_id;
import 'get_show_comments_test.dart' as show_comments;
import 'get_episode_comments_test.dart' as episode_comments;

void main() {
  group('Shows API Tests', () {
    // Run all test groups from each file
    show_by_id.main();
    seasons.main();
    season_episodes.main();
    episode_info.main();
    show_comments.main();
    related_shows.main();
    episode_comments.main();
  });
}
