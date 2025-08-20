import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @relatedShows.
  ///
  /// In en, this message translates to:
  /// **'Related Shows'**
  String get relatedShows;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @myShows.
  ///
  /// In en, this message translates to:
  /// **'My Shows'**
  String get myShows;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @trendingShows.
  ///
  /// In en, this message translates to:
  /// **'Trending Shows'**
  String get trendingShows;

  /// No description provided for @popularShows.
  ///
  /// In en, this message translates to:
  /// **'Popular Shows'**
  String get popularShows;

  /// No description provided for @showStatusReturningSeries.
  ///
  /// In en, this message translates to:
  /// **'Returning Series'**
  String get showStatusReturningSeries;

  /// No description provided for @showStatusInProduction.
  ///
  /// In en, this message translates to:
  /// **'In Production'**
  String get showStatusInProduction;

  /// No description provided for @showStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get showStatusPlanned;

  /// No description provided for @showStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get showStatusUpcoming;

  /// No description provided for @showStatusPilot.
  ///
  /// In en, this message translates to:
  /// **'Pilot'**
  String get showStatusPilot;

  /// No description provided for @showStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get showStatusCanceled;

  /// No description provided for @showStatusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get showStatusEnded;

  /// No description provided for @genreAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genreAction;

  /// No description provided for @genreAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genreAdventure;

  /// No description provided for @genreAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get genreAnimation;

  /// No description provided for @genreAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get genreAnime;

  /// No description provided for @genreComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get genreComedy;

  /// No description provided for @genreCrime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get genreCrime;

  /// No description provided for @genreDisaster.
  ///
  /// In en, this message translates to:
  /// **'Disaster'**
  String get genreDisaster;

  /// No description provided for @genreDocumentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get genreDocumentary;

  /// No description provided for @genreDonghua.
  ///
  /// In en, this message translates to:
  /// **'Donghua'**
  String get genreDonghua;

  /// No description provided for @genreDrama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get genreDrama;

  /// No description provided for @genreEastern.
  ///
  /// In en, this message translates to:
  /// **'Eastern'**
  String get genreEastern;

  /// No description provided for @genreFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get genreFamily;

  /// No description provided for @genreFanFilm.
  ///
  /// In en, this message translates to:
  /// **'Fan Film'**
  String get genreFanFilm;

  /// No description provided for @genreFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genreFantasy;

  /// No description provided for @genreFilmNoir.
  ///
  /// In en, this message translates to:
  /// **'Film Noir'**
  String get genreFilmNoir;

  /// No description provided for @genreHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get genreHistory;

  /// No description provided for @genreHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get genreHoliday;

  /// No description provided for @genreHorror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get genreHorror;

  /// No description provided for @genreIndie.
  ///
  /// In en, this message translates to:
  /// **'Indie'**
  String get genreIndie;

  /// No description provided for @genreMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get genreMusic;

  /// No description provided for @genreMusical.
  ///
  /// In en, this message translates to:
  /// **'Musical'**
  String get genreMusical;

  /// No description provided for @genreMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genreMystery;

  /// No description provided for @genreNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get genreNone;

  /// No description provided for @genreRoad.
  ///
  /// In en, this message translates to:
  /// **'Road'**
  String get genreRoad;

  /// No description provided for @genreRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreScienceFiction.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get genreScienceFiction;

  /// No description provided for @genreShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get genreShort;

  /// No description provided for @genreSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get genreSports;

  /// No description provided for @genreSportingEvent.
  ///
  /// In en, this message translates to:
  /// **'Sporting Event'**
  String get genreSportingEvent;

  /// No description provided for @genreSuspense.
  ///
  /// In en, this message translates to:
  /// **'Suspense'**
  String get genreSuspense;

  /// No description provided for @genreThriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genreThriller;

  /// No description provided for @genreTvMovie.
  ///
  /// In en, this message translates to:
  /// **'TV Movie'**
  String get genreTvMovie;

  /// No description provided for @genreWar.
  ///
  /// In en, this message translates to:
  /// **'War'**
  String get genreWar;

  /// No description provided for @genreWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get genreWestern;

  /// No description provided for @runtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String runtimeMinutes(Object minutes);

  /// No description provided for @noVideosMatchingFilters.
  ///
  /// In en, this message translates to:
  /// **'No videos match the filters'**
  String get noVideosMatchingFilters;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @mostFavoritedWeekly.
  ///
  /// In en, this message translates to:
  /// **'Most Favorited (7 days)'**
  String get mostFavoritedWeekly;

  /// No description provided for @mostFavoritedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Most Favorited (30 days)'**
  String get mostFavoritedMonthly;

  /// No description provided for @errorLoadingMoreShows.
  ///
  /// In en, this message translates to:
  /// **'Error loading more shows'**
  String get errorLoadingMoreShows;

  /// No description provided for @noShowsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No shows available'**
  String get noShowsAvailable;

  /// No description provided for @mostCollectedWeekly.
  ///
  /// In en, this message translates to:
  /// **'Most Collected (7 days)'**
  String get mostCollectedWeekly;

  /// No description provided for @mostPlayedWeekly.
  ///
  /// In en, this message translates to:
  /// **'Most Played (7 days)'**
  String get mostPlayedWeekly;

  /// No description provided for @mostWatchedWeekly.
  ///
  /// In en, this message translates to:
  /// **'Most Watched (7 days)'**
  String get mostWatchedWeekly;

  /// No description provided for @mostAnticipated.
  ///
  /// In en, this message translates to:
  /// **'Most Anticipated'**
  String get mostAnticipated;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @revokeToken.
  ///
  /// In en, this message translates to:
  /// **'Revoke Trakt.tv Token'**
  String get revokeToken;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @changeCountry.
  ///
  /// In en, this message translates to:
  /// **'Change Country'**
  String get changeCountry;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @noVideosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideosAvailable;

  /// No description provided for @seasonEpisodeFormat.
  ///
  /// In en, this message translates to:
  /// **'S{season}E{episode}'**
  String seasonEpisodeFormat(Object episode, Object season);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @episodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {episodeNumber}'**
  String episodeNumber(Object episodeNumber);

  /// No description provided for @allEpisodesWatched.
  ///
  /// In en, this message translates to:
  /// **'All episodes watched'**
  String get allEpisodesWatched;

  /// No description provided for @checkOutAllEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Check Out All Episodes'**
  String get checkOutAllEpisodes;

  /// No description provided for @episodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Episode Info'**
  String get episodeInfo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
