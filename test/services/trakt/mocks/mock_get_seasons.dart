List<Map<String, dynamic>> getMockSeasonsResponse() {
  return [
    {
      "number": 0,
      "ids": {"trakt": 1, "tvdb": 137481, "tmdb": 3627},
    },
    {
      "number": 1,
      "ids": {"trakt": 2, "tvdb": 364731, "tmdb": 3624},
    },
    {
      "number": 2,
      "ids": {"trakt": 3, "tvdb": 473271, "tmdb": 3625},
    },
    {
      "number": 3,
      "ids": {"trakt": 4, "tvdb": 488434, "tmdb": 3626},
    },
    {
      "number": 4,
      "ids": {"trakt": 5, "tvdb": 522882, "tmdb": 3628},
    },
  ];
}

List<Map<String, dynamic>> getMockExtendedSeasonsResponse() {
  return [
    {
      "number": 0,
      "ids": {"trakt": 1, "tvdb": 137481, "tmdb": 3627},
      "rating": 9,
      "votes": 111,
      "episode_count": 10,
      "aired_episodes": 10,
      "title": "Specials",
      "overview": null,
      "first_aired": "2010-12-06T02:00:00.000Z",
      "udpated_at": "2010-12-07T01:023:00.000Z",
      "network": "HBO",
      "original_title": null,
    },
    {
      "number": 1,
      "ids": {"trakt": 2, "tvdb": 364731, "tmdb": 3624},
      "rating": 9,
      "votes": 111,
      "episode_count": 10,
      "aired_episodes": 10,
      "title": "Season 1",
      "overview": "Season 1 overview.",
      "first_aired": "2011-04-09T02:00:00.000Z",
      "udpated_at": "2010-12-07T01:023:00.000Z",
      "network": "HBO",
      "original_title": "Season 1",
    },
    {
      "number": 2,
      "ids": {"trakt": 3, "tvdb": 473271, "tmdb": 3625},
      "rating": 9,
      "votes": 111,
      "episode_count": 10,
      "aired_episodes": 10,
      "title": "Season 2",
      "overview": "Season 2 overview.",
      "first_aired": "2012-04-02T02:00:00.000Z",
      "udpated_at": "2010-12-07T01:023:00.000Z",
      "network": "HBO",
      "original_title": null,
    },
    {
      "number": 3,
      "ids": {"trakt": 4, "tvdb": 488434, "tmdb": 3626},
      "rating": 9,
      "votes": 111,
      "episode_count": 10,
      "aired_episodes": 10,
      "title": "Season 3",
      "overview": "Season 3 overview.",
      "first_aired": "2013-04-01T02:00:00.000Z",
      "udpated_at": "2010-12-07T01:023:00.000Z",
      "network": "HBO",
      "original_title": null,
    },
    {
      "number": 4,
      "ids": {"trakt": 5, "tvdb": 522882, "tmdb": 3628},
      "rating": 9,
      "votes": 111,
      "episode_count": 10,
      "aired_episodes": 10,
      "title": "Season 4",
      "overview": "Season 4 overview",
      "first_aired": "2014-04-07T02:00:00.000Z",
      "udpated_at": "2010-12-07T01:023:00.000Z",
      "network": "HBO",
      "original_title": null,
    },
  ];
}

List<Map<String, dynamic>> getMockSeasonsWithEpisodesResponse() {
  return [
    {
      "number": 0,
      "ids": {"trakt": 1, "tvdb": 137481, "tmdb": 3627},
      "episodes": [
        {
          "season": 0,
          "number": 1,
          "title": "Inside Game of Thrones",
          "ids": {"trakt": 36430, "tvdb": 3226241, "imdb": "", "tmdb": 63087},
        },
        {
          "season": 0,
          "number": 2,
          "title": "15-Minute Preview",
          "ids": {"trakt": 36431, "tvdb": 4045941, "imdb": "", "tmdb": 63086},
        },
      ],
    },
    {
      "number": 1,
      "ids": {"trakt": 2, "tvdb": 364731, "tmdb": 3624},
      "episodes": [
        {
          "season": 1,
          "number": 1,
          "title": "Winter Is Coming",
          "ids": {
            "trakt": 36440,
            "tvdb": 3254641,
            "imdb": "tt1480055",
            "tmdb": 63056,
          },
        },
        {
          "season": 1,
          "number": 2,
          "title": "The Kingsroad",
          "ids": {
            "trakt": 36441,
            "tvdb": 3436411,
            "imdb": "tt1668746",
            "tmdb": 63057,
          },
        },
      ],
    },
    {
      "number": 2,
      "ids": {"trakt": 3, "tvdb": 473271, "tmdb": 3625},
      "episodes": [
        {
          "season": 2,
          "number": 1,
          "title": "The North Remembers",
          "ids": {
            "trakt": 36450,
            "tvdb": 4161693,
            "imdb": "tt1971833",
            "tmdb": 63066,
          },
        },
        {
          "season": 2,
          "number": 2,
          "title": "The Night Lands",
          "ids": {
            "trakt": 36451,
            "tvdb": 4245771,
            "imdb": "tt2069318",
            "tmdb": 974430,
          },
        },
      ],
    },
    {
      "number": 3,
      "ids": {"trakt": 4, "tvdb": 488434, "tmdb": 3626},
      "episodes": [
        {
          "season": 3,
          "number": 1,
          "title": "Valar Dohaeris",
          "ids": {
            "trakt": 36460,
            "tvdb": 4293685,
            "imdb": "tt2178782",
            "tmdb": 63077,
          },
        },
        {
          "season": 3,
          "number": 2,
          "title": "Dark Wings, Dark Words",
          "ids": {
            "trakt": 36461,
            "tvdb": 4517458,
            "imdb": "tt2178772",
            "tmdb": 63076,
          },
        },
      ],
    },
    {
      "number": 4,
      "ids": {"trakt": 5, "tvdb": 522882, "tmdb": 3628},
      "episodes": [
        {
          "season": 4,
          "number": 1,
          "title": "Two Swords",
          "ids": {
            "trakt": 36470,
            "tvdb": 4721938,
            "imdb": "tt2816136",
            "tmdb": 973190,
          },
        },
        {
          "season": 4,
          "number": 2,
          "title": "The Lion and the Rose",
          "ids": {
            "trakt": 36471,
            "tvdb": 4801602,
            "imdb": "tt2832378",
            "tmdb": 973219,
          },
        },
      ],
    },
    {
      "number": 5,
      "ids": {"trakt": 6, "tvdb": null, "tmdb": 62090},
      "episodes": [
        {
          "season": 5,
          "number": 1,
          "title": "5x1",
          "ids": {"trakt": 63767, "tvdb": null, "imdb": "", "tmdb": 1001402},
        },
      ],
    },
  ];
}
