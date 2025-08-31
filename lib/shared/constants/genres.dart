import 'package:watching/l10n/app_localizations.dart';

/// Constants for TV show and movie genres
class Genres {
  // Common genre names
  static const String action = 'Action';
  static const String adventure = 'Adventure';
  static const String animation = 'Animation';
  static const String anime = 'Anime';
  static const String comedy = 'Comedy';
  static const String crime = 'Crime';
  static const String disaster = 'Disaster';
  static const String documentary = 'Documentary';
  static const String donghua = 'Donghua';
  static const String drama = 'Drama';
  static const String eastern = 'Eastern';
  static const String family = 'Family';
  static const String fanFilm = 'Fan Film';
  static const String fantasy = 'Fantasy';
  static const String filmNoir = 'Film Noir';
  static const String history = 'History';
  static const String holiday = 'Holiday';
  static const String horror = 'Horror';
  static const String indie = 'Indie';
  static const String music = 'Music';
  static const String musical = 'Musical';
  static const String mystery = 'Mystery';
  static const String none = 'None';
  static const String road = 'Road';
  static const String romance = 'Romance';
  static const String scienceFiction = 'Science Fiction';
  static const String short = 'Short';
  static const String sports = 'Sports';
  static const String sportingEvent = 'Sporting Event';
  static const String suspense = 'Suspense';
  static const String thriller = 'Thriller';
  static const String tvMovie = 'TV Movie';
  static const String war = 'War';
  static const String western = 'Western';

  /// List of all available genres
  static const List<String> all = [
    action,
    adventure,
    animation,
    anime,
    comedy,
    crime,
    disaster,
    documentary,
    donghua,
    drama,
    eastern,
    family,
    fanFilm,
    fantasy,
    filmNoir,
    history,
    holiday,
    horror,
    indie,
    music,
    musical,
    mystery,
    none,
    road,
    romance,
    scienceFiction,
    short,
    sports,
    sportingEvent,
    suspense,
    thriller,
    tvMovie,
    war,
    western,
  ];

  /// Get the translated genre name
  static String getTranslatedGenre(String genre, AppLocalizations l10n) {
    // Normalize the input genre to handle case differences and extra spaces
    final normalizedGenre = genre.trim();

    // Handle common variations that might come from the API
    final genreMap = {
      // Direct matches (case insensitive)
      'action': action,
      'adventure': adventure,
      'animation': animation,
      'anime': anime,
      'comedy': comedy,
      'crime': crime,
      'disaster': disaster,
      'documentary': documentary,
      'donghua': donghua,
      'drama': drama,
      'eastern': eastern,
      'family': family,
      'fan film': fanFilm,
      'fantasy': fantasy,
      'film noir': filmNoir,
      'history': history,
      'holiday': holiday,
      'horror': horror,
      'indie': indie,
      'music': music,
      'musical': musical,
      'mystery': mystery,
      'none': none,
      'road': road,
      'romance': romance,
      'science fiction': scienceFiction,
      'short': short,
      'sports': sports,
      'sporting event': sportingEvent,
      'suspense': suspense,
      'thriller': thriller,
      'tv movie': tvMovie,
      'war': war,
      'western': western,
    };

    // Try to find a match (case insensitive)
    final key = normalizedGenre.toLowerCase();
    final matchedGenre = genreMap[key];

    if (matchedGenre != null) {
      switch (matchedGenre) {
        case action:
          return l10n.genreAction;
        case adventure:
          return l10n.genreAdventure;
        case animation:
          return l10n.genreAnimation;
        case anime:
          return l10n.genreAnime;
        case comedy:
          return l10n.genreComedy;
        case crime:
          return l10n.genreCrime;
        case disaster:
          return l10n.genreDisaster;
        case documentary:
          return l10n.genreDocumentary;
        case donghua:
          return l10n.genreDonghua;
        case drama:
          return l10n.genreDrama;
        case eastern:
          return l10n.genreEastern;
        case family:
          return l10n.genreFamily;
        case fanFilm:
          return l10n.genreFanFilm;
        case fantasy:
          return l10n.genreFantasy;
        case filmNoir:
          return l10n.genreFilmNoir;
        case history:
          return l10n.genreHistory;
        case holiday:
          return l10n.genreHoliday;
        case horror:
          return l10n.genreHorror;
        case indie:
          return l10n.genreIndie;
        case music:
          return l10n.genreMusic;
        case musical:
          return l10n.genreMusical;
        case mystery:
          return l10n.genreMystery;
        case none:
          return l10n.genreNone;
        case road:
          return l10n.genreRoad;
        case romance:
          return l10n.genreRomance;
        case scienceFiction:
          return l10n.genreScienceFiction;
        case short:
          return l10n.genreShort;
        case sports:
          return l10n.genreSports;
        case sportingEvent:
          return l10n.genreSportingEvent;
        case suspense:
          return l10n.genreSuspense;
        case thriller:
          return l10n.genreThriller;
        case tvMovie:
          return l10n.genreTvMovie;
        case war:
          return l10n.genreWar;
        case western:
          return l10n.genreWestern;
      }
    }

    // If no match found, return the original genre
    return genre;
  }
}
