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
  String get showStatusReturningSeries => 'Returning Series';

  @override
  String get showStatusInProduction => 'In Production';

  @override
  String get showStatusPlanned => 'Planned';

  @override
  String get showStatusUpcoming => 'Upcoming';

  @override
  String get showStatusPilot => 'Pilot';

  @override
  String get showStatusCanceled => 'Canceled';

  @override
  String get showStatusEnded => 'Ended';

  @override
  String get genreAction => 'Action';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreAnimation => 'Animation';

  @override
  String get genreAnime => 'Anime';

  @override
  String get genreComedy => 'Comedy';

  @override
  String get genreCrime => 'Crime';

  @override
  String get genreDisaster => 'Disaster';

  @override
  String get genreDocumentary => 'Documentary';

  @override
  String get genreDonghua => 'Donghua';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreEastern => 'Eastern';

  @override
  String get genreFamily => 'Family';

  @override
  String get genreFanFilm => 'Fan Film';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreFilmNoir => 'Film Noir';

  @override
  String get genreHistory => 'History';

  @override
  String get genreHoliday => 'Holiday';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreIndie => 'Indie';

  @override
  String get genreMusic => 'Music';

  @override
  String get genreMusical => 'Musical';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreNone => 'None';

  @override
  String get genreRoad => 'Road';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreScienceFiction => 'Science Fiction';

  @override
  String get genreShort => 'Short';

  @override
  String get genreSports => 'Sports';

  @override
  String get genreSportingEvent => 'Sporting Event';

  @override
  String get genreSuspense => 'Suspense';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreTvMovie => 'TV Movie';

  @override
  String get genreWar => 'War';

  @override
  String get genreWestern => 'Western';

  @override
  String runtimeMinutes(Object minutes) {
    return '$minutes min';
  }

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

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get searchHint => 'Search...';

  @override
  String get movies => 'Movies';

  @override
  String get shows => 'TV Shows';

  @override
  String get selectAtLeastOneType =>
      'Select at least one type (Movie or TV Show)';

  @override
  String get searchError => 'Error searching. Please try again.';

  @override
  String get noSearchTerm => 'Enter a search term';

  @override
  String noSearchResults(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get retry => 'Retry';

  @override
  String get spoiler => 'SPOILER';

  @override
  String get review => 'REVIEW';

  @override
  String get sortOptionLikes => 'Most Likes';

  @override
  String get sortOptionNewest => 'Newest';

  @override
  String get sortOptionOldest => 'Oldest';

  @override
  String get sortOptionReplies => 'Most Replies';

  @override
  String get sortOptionHighest => 'Highest Rated';

  @override
  String get sortOptionLowest => 'Lowest Rated';

  @override
  String get sortOptionPlays => 'Most Plays';

  @override
  String get sortOptionWatched => 'Most Watched';

  @override
  String get filters => 'Filters';

  @override
  String get comments => 'Comments';

  @override
  String get watched => 'Watched';

  @override
  String get unwatched => 'Not watched';

  @override
  String get errorLoadingComments => 'Error loading comments';

  @override
  String get ok => 'OK';
}
