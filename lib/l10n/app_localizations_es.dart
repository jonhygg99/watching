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
    return 'T${season}E$episode';
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
  String get checkOutAllEpisodes => 'Ver todos los episodios';

  @override
  String get episodeInfo => 'Información del episodio';
}
