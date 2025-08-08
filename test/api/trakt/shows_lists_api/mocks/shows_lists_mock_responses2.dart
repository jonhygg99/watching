// ignore_for_file: lines_longer_than_80_chars

/// Mock responses for ShowsListsApi tests
class ShowsListsMockResponses {
  static const trendingShowsResponse = [
    {
      "watchers": 541,
      "show": {
        "title": "Breaking Bad",
        "year": 2008,
        "ids": {
          "trakt": 1,
          "slug": "breaking-bad",
          "tvdb": 81189,
          "imdb": "tt0903747",
          "tmdb": 1396,
        },
      },
    },
    {
      "watchers": 432,
      "show": {
        "title": "The Walking Dead",
        "year": 2010,
        "ids": {
          "trakt": 2,
          "slug": "the-walking-dead",
          "tvdb": 153021,
          "imdb": "tt1520211",
          "tmdb": 1402,
        },
      },
    },
  ];

  static const popularShowsResponse = [
    {
      "title": "Community",
      "year": 2009,
      "ids": {
        "trakt": 41,
        "slug": "community",
        "tvdb": 94571,
        "imdb": "tt1439629",
        "tmdb": 18347
      }
    },
    {
      "title": "The Walking Dead",
      "year": 2010,
      "ids": {
        "trakt": 2,
        "slug": "the-walking-dead",
        "tvdb": 153021,
        "imdb": "tt1520211",
        "tmdb": 1402
      }
    },
    {
      "title": "Dexter",
      "year": 2006,
      "ids": {
        "trakt": 19,
        "slug": "dexter",
        "tvdb": 79349,
        "imdb": "tt0773262",
        "tmdb": 1405
      }
    },
    {
      "title": "The Simpsons",
      "year": 1989,
      "ids": {
        "trakt": 91,
        "slug": "the-simpsons",
        "tvdb": 71663,
        "imdb": "tt0096697",
        "tmdb": 456
      }
    },
    {
      "title": "Game of Thrones",
      "year": 2011,
      "ids": {
        "trakt": 353,
        "slug": "game-of-thrones",
        "tvdb": 121361,
        "imdb": "tt0944947",
        "tmdb": 1399
      }
    },
    {
      "title": "Lost",
      "year": 2004,
      "ids": {
        "trakt": 511,
        "slug": "lost",
        "tvdb": 73739,
        "imdb": "tt0411008",
        "tmdb": 4607
      }
    },
    {
      "title": "24",
      "year": 2001,
      "ids": {
        "trakt": 460,
        "slug": "24",
        "tvdb": 76290,
        "imdb": "tt0285331",
        "tmdb": 1973
      }
    },
    {
      "title": "Battlestar Galactica",
      "year": 2005,
      "ids": {
        "trakt": 331,
        "slug": "battlestar-galactica",
        "tvdb": 73545,
        "imdb": "tt0407362",
        "tmdb": 1972
      }
    },
    {
      "title": "Breaking Bad",
      "year": 2008,
      "ids": {
        "trakt": 1,
        "slug": "breaking-bad",
        "tvdb": 81189,
        "imdb": "tt0903747",
        "tmdb": 1396
      }
    },
    {
      "title": "Firefly",
      "year": 2002,
      "ids": {
        "trakt": 329,
        "slug": "firefly",
        "tvdb": 78874,
        "imdb": "tt0303461",
        "tmdb": 1437
      }
    }
  ];

  static const mostFavoritedShowsResponse = [
    {
      "user_count": 155291,
      "show": {
        "title": "The Big Bang Theory",
        "year": 2007,
        "ids": {
          "trakt": 1409,
          "slug": "the-big-bang-theory",
          "tvdb": 80379,
          "imdb": "tt0898266",
          "tmdb": 1418
        }
      }
    },
    {
      "user_count": 46170,
      "show": {
        "title": "Grey's Anatomy",
        "year": 2005,
        "ids": {
          "trakt": 1407,
          "slug": "grey-s-anatomy",
          "tvdb": 73762,
          "imdb": "tt0413573",
          "tmdb": 1416
        }
      }
    },
    {
      "user_count": 203742,
      "show": {
        "title": "Game of Thrones",
        "year": 2011,
        "ids": {
          "trakt": 1390,
          "slug": "game-of-thrones",
          "tvdb": 121361,
          "imdb": "tt0944947",
          "tmdb": 1399
        }
      }
    }
  ];
}
