// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Watching';

  @override
  String get language => 'Idioma';

  @override
  String get settings => 'Ajustes';

  @override
  String get discover => 'Descubrir';

  @override
  String get relatedShows => 'Series relacionadas';

  @override
  String get videos => 'Vídeos';

  @override
  String get viewMore => 'Ver más';

  @override
  String get watchlist => 'Mi lista';

  @override
  String get myShows => 'Mis series';

  @override
  String get search => 'Buscar';

  @override
  String get trendingShows => 'Series en tendencia';

  @override
  String get popularShows => 'Series populares';

  @override
  String get showStatusReturningSeries => 'En emisión';

  @override
  String get showStatusInProduction => 'En producción';

  @override
  String get showStatusPlanned => 'Planificada';

  @override
  String get showStatusUpcoming => 'Próximamente';

  @override
  String get showStatusPilot => 'Piloto';

  @override
  String get showStatusCanceled => 'Cancelada';

  @override
  String get showStatusEnded => 'Terminada';

  @override
  String get genreAction => 'Acción';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreAnimation => 'Animación';

  @override
  String get genreAnime => 'Anime';

  @override
  String get genreComedy => 'Comedia';

  @override
  String get genreCrime => 'Crimen';

  @override
  String get genreDisaster => 'Desastre';

  @override
  String get genreDocumentary => 'Documental';

  @override
  String get genreDonghua => 'Donghua';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreEastern => 'Oriental';

  @override
  String get genreFamily => 'Familiar';

  @override
  String get genreFanFilm => 'Película de fans';

  @override
  String get genreFantasy => 'Fantasía';

  @override
  String get genreFilmNoir => 'Cine negro';

  @override
  String get genreHistory => 'Historia';

  @override
  String get genreHoliday => 'Navideño';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genreIndie => 'Independiente';

  @override
  String get genreMusic => 'Música';

  @override
  String get genreMusical => 'Musical';

  @override
  String get genreMystery => 'Misterio';

  @override
  String get genreNone => 'Ninguno';

  @override
  String get genreRoad => 'Road Movie';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreScienceFiction => 'Ciencia Ficción';

  @override
  String get genreShort => 'Corto';

  @override
  String get genreSports => 'Deportes';

  @override
  String get genreSportingEvent => 'Evento Deportivo';

  @override
  String get genreSuspense => 'Suspense';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreTvMovie => 'Película de TV';

  @override
  String get genreWar => 'Bélica';

  @override
  String get genreWestern => 'Western';

  @override
  String runtimeMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get noVideosMatchingFilters =>
      'No hay videos que coincidan con los filtros';

  @override
  String get noTitle => 'Sin título';

  @override
  String get mostFavoritedWeekly => 'Más favoritas (7 días)';

  @override
  String get mostFavoritedMonthly => 'Más favoritas (30 días)';

  @override
  String get errorLoadingMoreShows => 'Error al cargar más series';

  @override
  String get noShowsAvailable => 'No hay series disponibles';

  @override
  String get mostCollectedWeekly => 'Más añadidas (7 días)';

  @override
  String get mostPlayedWeekly => 'Más reproducidas (7 días)';

  @override
  String get mostWatchedWeekly => 'Más vistas (7 días)';

  @override
  String get mostAnticipated => 'Más esperadas';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get noResults => 'No se encontraron resultados';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get noDataFound => 'No se encontraron datos';

  @override
  String get system => 'Sistema';

  @override
  String get revokeToken => 'Revocar token de Trakt.tv';

  @override
  String get country => 'País';

  @override
  String get changeCountry => 'Cambiar país';

  @override
  String get user => 'Usuario';

  @override
  String get noImage => 'Sin imagen';

  @override
  String get noVideosAvailable => 'No hay vídeos disponibles';

  @override
  String seasonEpisodeFormat(Object episode, Object season) {
    return 'T$season E$episode';
  }

  @override
  String get errorLoadingData => 'Error al cargar los datos';

  @override
  String episodeNumber(Object episodeNumber) {
    return 'Episodio $episodeNumber';
  }

  @override
  String get allEpisodesWatched => 'Todos los episodios vistos';

  @override
  String get checkOutAllEpisodes => 'Ver episodios';

  @override
  String get episodeInfo => 'Detalles del episodio';

  @override
  String get errorMarkingEpisode => 'Error al marcar el episodio';

  @override
  String get markingAsUnwatched => 'Marcando como no visto...';

  @override
  String get markingAsWatched => 'Marcando como visto...';

  @override
  String get noCommentsYet => 'Aún no hay comentarios';

  @override
  String get searchHint => 'Buscar...';

  @override
  String get movies => 'Películas';

  @override
  String get shows => 'Series';

  @override
  String get selectAtLeastOneType =>
      'Selecciona al menos un tipo (Película o Serie)';

  @override
  String get searchError => 'Error al buscar. Por favor, inténtalo de nuevo.';

  @override
  String get noSearchTerm => 'Ingresa un término de búsqueda';

  @override
  String noSearchResults(Object query) {
    return 'No se encontraron resultados para \"$query\"';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get spoiler => 'SPOILER';

  @override
  String get review => 'RESEÑA';

  @override
  String get sortOptionLikes => 'Más Me Gusta';

  @override
  String get sortOptionNewest => 'Más Recientes';

  @override
  String get sortOptionOldest => 'Más Antiguos';

  @override
  String get sortOptionReplies => 'Más Respuestas';

  @override
  String get sortOptionHighest => 'Mejor Valorados';

  @override
  String get sortOptionLowest => 'Peor Valorados';

  @override
  String get sortOptionPlays => 'Más Reproducidos';

  @override
  String get sortOptionWatched => 'Más Vistos';

  @override
  String get filters => 'Filtros';

  @override
  String get comments => 'Comentarios';

  @override
  String get watched => 'Visto';

  @override
  String get unwatched => 'No visto';

  @override
  String get errorLoadingComments => 'Error al cargar los comentarios';

  @override
  String get ok => 'Aceptar';

  @override
  String get noProgressAvailable => 'Sin progreso disponible';

  @override
  String get authenticationError => 'Error al verificar la autenticación';

  @override
  String get noItemsInWatchlist =>
      'No hay elementos en la lista de seguimiento';

  @override
  String get endedShows => 'Series finalizadas';

  @override
  String get upcomingShows => 'Próximas series';

  @override
  String get errorLoadingShows => 'Error al cargar las series';

  @override
  String get errorLoadingUpcomingEpisodes =>
      'Error al cargar los próximos episodios';

  @override
  String get episodeAired => 'Emitido';

  @override
  String get episodeToday => 'Hoy';

  @override
  String episodeDaysAway(Object days) {
    return '$days días';
  }

  @override
  String get calendarDataError => 'Error al cargar los datos del Calendario';

  @override
  String get upcomingEpisodes => 'Próximos Episodios';

  @override
  String get noShowsFound => 'No se encontraron series';

  @override
  String get noEpisodeInfo => 'No hay información del episodio';

  @override
  String get removeFromHistory => 'Eliminar episodio del historial';

  @override
  String get markAsWatched => 'Marcar como visto';

  @override
  String get previousSeason => 'Temporada Anterior';

  @override
  String get nextSeason => 'Próxima Temporada';

  @override
  String seasonTitle(Object seasonNumber) {
    return 'Temporada $seasonNumber';
  }

  @override
  String get readMore => 'Leer más';

  @override
  String get readLess => 'Leer menos';

  @override
  String get monthNamesShort =>
      'Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic';

  @override
  String get daysLeftText => 'días';

  @override
  String get seasonPremiere => 'Estreno de Temporada';

  @override
  String get hideEpisodes => 'Ocultar episodios';

  @override
  String showMoreEpisodes(Object count) {
    return 'Mostrar $count episodios más';
  }
}
