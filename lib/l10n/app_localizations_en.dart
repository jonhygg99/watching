// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Watching';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get discover => 'Discover';

  @override
  String get relatedShows => 'Related Shows';

  @override
  String get videos => 'Videos';

  @override
  String get viewMore => 'View More';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get myShows => 'My Shows';

  @override
  String get search => 'Search';

  @override
  String get trendingShows => 'Trending Shows';

  @override
  String get popularShows => 'Popular Shows';

  @override
  String get noVideosMatchingFilters => 'No videos match the filters';

  @override
  String get noTitle => 'No title';

  @override
  String get mostFavoritedWeekly => 'Most Favorited (7 days)';

  @override
  String get mostFavoritedMonthly => 'Most Favorited (30 days)';

  @override
  String get errorLoadingMoreShows => 'Error loading more shows';

  @override
  String get noShowsAvailable => 'No shows available';

  @override
  String get mostCollectedWeekly => 'Most Collected (7 days)';

  @override
  String get mostPlayedWeekly => 'Most Played (7 days)';

  @override
  String get mostWatchedWeekly => 'Most Watched (7 days)';

  @override
  String get mostAnticipated => 'Most Anticipated';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get noResults => 'No results found';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get noDataFound => 'No data found';

  @override
  String get system => 'System';

  @override
  String get revokeToken => 'Revoke Trakt.tv Token';

  @override
  String get country => 'Country';

  @override
  String get changeCountry => 'Change Country';

  @override
  String get user => 'User';

  @override
  String get noImage => 'No image';

  @override
  String get noVideosAvailable => 'No videos available';

  @override
  String seasonEpisodeFormat(Object episode, Object season) {
    return 'S${season}E$episode';
  }

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String episodeNumber(Object episodeNumber) {
    return 'Episode $episodeNumber';
  }

  @override
  String get allEpisodesWatched => 'All episodes watched';

  @override
  String get checkOutAllEpisodes => 'Check Out All Episodes';

  @override
  String get episodeInfo => 'Episode Info';
}
