Map<String, dynamic> getMockShowResponse() {
  return {
    'title': 'Game of Thrones',
    'year': 2011,
    'ids': {
      'trakt': 353,
      'slug': 'game-of-thrones',
      'tvdb': 121361,
      'imdb': 'tt0944947',
      'tmdb': 1399,
    },
  };
}

Map<String, dynamic> getMockExtendedShowResponse() {
  return {
    ...getMockShowResponse(),
    'tagline': 'Winter Is Coming',
    'overview': 'Game of Thrones is an American fantasy drama television series created for HBO by David Benioff and D. B. Weiss. It is an adaptation of A Song of Ice and Fire, George R. R. Martin\'s series of fantasy novels, the first of which is titled A Game of Thrones.',
    'first_aired': '2011-04-18T01:00:00.000Z',
    'airs': {
      'day': 'Sunday',
      'time': '21:00',
      'timezone': 'America/New_York',
    },
    'runtime': 60,
    'certification': 'TV-MA',
    'network': 'HBO',
    'country': 'us',
    'updated_at': '2014-08-22T08:32:06.000Z',
    'trailer': null,
    'homepage': 'http://www.hbo.com/game-of-thrones/index.html',
    'status': 'returning series',
    'rating': 9,
    'votes': 111,
    'comment_count': 92,
    'languages': ['en'],
    'available_translations': [
      'en', 'tr', 'sk', 'de', 'ru', 'fr', 'hu', 'zh', 'el', 'pt',
      'es', 'bg', 'ro', 'it', 'ko', 'he', 'nl', 'pl'
    ],
    'genres': ['drama', 'fantasy'],
    'aired_episodes': 50,
    'original_title': 'Game of Thrones',
  };
}
