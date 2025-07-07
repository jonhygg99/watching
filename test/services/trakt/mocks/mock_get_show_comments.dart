List<Map<String, dynamic>> getMockShowComments() {
  return [
    {
      "id": 12345,
      "parent_id": 0,
      "created_at": "2023-01-15T10:30:00.000Z",
      "updated_at": "2023-01-15T10:30:00.000Z",
      "comment": "This show is absolutely amazing! The character development is on point.",
      "spoiler": false,
      "review": false,
      "replies": 5,
      "likes": 24,
      "user_rating": 9.0,
      "user": {
        "username": "tvfan123",
        "private": false,
        "name": "TV Fan",
        "vip": true,
        "vip_ep": true,
        "ids": {
          "slug": "tvfan123"
        }
      }
    },
    {
      "id": 12346,
      "parent_id": 0,
      "created_at": "2023-01-14T08:15:00.000Z",
      "updated_at": "2023-01-14T08:15:00.000Z",
      "comment": "The last episode was mind-blowing! Can't wait for the next season.",
      "spoiler": true,
      "review": false,
      "replies": 2,
      "likes": 15,
      "user_rating": 10.0,
      "user": {
        "username": "movielover",
        "private": true,
        "name": "Movie Lover",
        "vip": false,
        "vip_ep": false,
        "ids": {
          "slug": "movielover"
        }
      }
    },
    {
      "id": 12347,
      "parent_id": 12345,
      "created_at": "2023-01-15T11:00:00.000Z",
      "updated_at": "2023-01-15T11:00:00.000Z",
      "comment": "I completely agree! The character arcs are so well written.",
      "spoiler": false,
      "review": false,
      "replies": 0,
      "likes": 3,
      "user_rating": null,
      "user": {
        "username": "seriesaddict",
        "private": false,
        "name": "Series Addict",
        "vip": false,
        "vip_ep": true,
        "ids": {
          "slug": "seriesaddict"
        }
      }
    },
    {
      "id": 12348,
      "parent_id": 0,
      "created_at": "2023-01-13T20:45:00.000Z",
      "updated_at": "2023-01-13T20:45:00.000Z",
      "comment": "The cinematography in this show is absolutely stunning. Every frame could be a painting!",
      "spoiler": false,
      "review": true,
      "replies": 3,
      "likes": 42,
      "user_rating": 9.5,
      "user": {
        "username": "cinephile",
        "private": false,
        "name": "Cinephile",
        "vip": true,
        "vip_ep": true,
        "ids": {
          "slug": "cinephile"
        }
      }
    },
    {
      "id": 12349,
      "parent_id": 0,
      "created_at": "2023-01-12T14:20:00.000Z",
      "updated_at": "2023-01-12T14:20:00.000Z",
      "comment": "The plot twist in episode 5 was completely unexpected!",
      "spoiler": true,
      "review": false,
      "replies": 8,
      "likes": 31,
      "user_rating": 8.5,
      "user": {
        "username": "twistlover",
        "private": true,
        "name": "Twist Lover",
        "vip": false,
        "vip_ep": false,
        "ids": {
          "slug": "twistlover"
        }
      }
    }
  ];
}
