// Mock responses for SearchApi tests

final mockShowSearchResponse = [
  {
    'type': 'show',
    'score': 19.533358,
    'show': {
      'title': 'Tron: Uprising',
      'year': 2012,
      'ids': {
        'trakt': 34209,
        'slug': 'tron-uprising',
        'tvdb': 258480,
        'imdb': 'tt1812523',
        'tmdb': 34356
      }
    }
  }
];

final mockMovieSearchResponse = [
  {
    'type': 'movie',
    'score': 26.019499,
    'movie': {
      'title': 'TRON: Legacy',
      'year': 2010,
      'ids': {
        'trakt': 12601,
        'slug': 'tron-legacy-2010',
        'imdb': 'tt1104001',
        'tmdb': 20526
      }
    }
  }
];

final mockEmptySearchResponse = <dynamic>[];
