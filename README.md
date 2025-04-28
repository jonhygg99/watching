# watching

## Trakt.tv API Usage

### Pagination

Some methods are paginated. Methods with 📄 Pagination will load 1 page of 10 items by default. Methods with 📄 Pagination Optional will load all items by default. In either case, append a query string like `?page={page}&limit={limit}` to the URL to influence the results.

| Parameter | Type    | Default | Value                                    |
| --------- | ------- | ------- | ---------------------------------------- |
| page      | integer | 1       | Number of page of results to be returned |
| limit     | integer | 10      | Number of results to return per page     |

All paginated methods will return these HTTP headers:

| Header                  | Value                  |
| ----------------------- | ---------------------- |
| X-Pagination-Page       | Current page.          |
| X-Pagination-Limit      | Items per page.        |
| X-Pagination-Page-Count | Total number of pages. |
| X-Pagination-Item-Count | Total number of items. |

### Extended Info

By default, all methods will return minimal info for movies, shows, episodes, people, and users. Minimal info is typically all you need to match locally cached items and includes the title, year, and ids. However, you can request different extended levels of information by adding `?extended={level}` to the URL. Send a comma separated string to get multiple types of extended info.

> **NOTE:** This returns a lot of extra data, so please only use extended parameters if you actually need them!

| Level       | Description                                       |
| ----------- | ------------------------------------------------- |
| images      | Minimal info and all images.                      |
| full        | Complete info for an item.                        |
| full,images | Complete info and all images.                     |
| metadata    | Collection only. Additional video and audio info. |

### Filters

Some movies, shows, calendars, and search methods support additional filters and will be tagged with 🎚 Filters. Applying these filters refines the results and helps your users to more easily discover new items.

Add a query string (i.e. `?years=2016&genres=action`) with any filters you want to use. Some filters allow multiples which can be sent as comma delimited parameters. For example, `?genres=action,adventure` would match the action OR adventure genre.

> **NOTE:** Make sure to properly URL encode the parameters including spaces and special characters.

#### Common Filters

| Parameter  | Multiples | Example | Value                           |
| ---------- | --------- | ------- | ------------------------------- |
| query      |           | batman  | Search titles and descriptions. |
| years      |           | 2016    | 4 digit year or range of years. |
| genres     | ✓         | action  | Genre slugs.                    |
| languages  | ✓         | en      | 2 character language code.      |
| countries  | ✓         | us      | 2 character country code.       |
| runtimes   |           | 30-90   | Range in minutes.               |
| studio_ids | ✓         | 42      | Trakt studio ID.                |

#### Rating Filters

Trakt, TMDB, and IMDB ratings apply to movies, shows, and episodes. Rotten Tomatoes and Metacritic apply to movies.

| Parameter      | Multiples | Example    | Value                                                   |
| -------------- | --------- | ---------- | ------------------------------------------------------- |
| ratings        |           | 75-100     | Trakt rating range between 0 and 100.                   |
| votes          |           | 5000-10000 | Trakt vote count between 0 and 100000.                  |
| tmdb_ratings   |           | 5.5-10.0   | TMDB rating range between 0.0 and 10.0.                 |
| tmdb_votes     |           | 5000-10000 | TMDB vote count between 0 and 100000.                   |
| imdb_ratings   |           | 5.5-10.0   | IMDB rating range between 0.0 and 10.0.                 |
| imdb_votes     |           | 5000-10000 | IMDB vote count between 0 and 3000000.                  |
| rt_meters      |           | 55-1000    | Rotten Tomatoes tomatometer range between 0 and 100.    |
| rt_user_meters |           | 65-100     | Rotten Tomatoes audience score range between 0 and 100. |
| metascores     |           | 5.5-10.0   | Metacritic score range between 0 and 100                |

#### Movie Filters

| Parameter      | Multiples | Example | Value                     |
| -------------- | --------- | ------- | ------------------------- |
| certifications | ✓         | pg-13   | US content certification. |

#### Show Filters

| Parameter      | Multiples | Example | Value                                                                                             |
| -------------- | --------- | ------- | ------------------------------------------------------------------------------------------------- |
| certifications | ✓         | tv-pg   | US content certification.                                                                         |
| network_ids    | ✓         | 53      | Trakt network ID.                                                                                 |
| status         | ✓         | ended   | Set to returning series, continuing, in production, planned, upcoming, pilot, canceled, or ended. |

#### Episode Filters

| Parameter      | Multiples | Example             | Value                                                                                                                       |
| -------------- | --------- | ------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| certifications | ✓         | tv-pg               | US content certification.                                                                                                   |
| network_ids    | ✓         | 53                  | Trakt network ID.                                                                                                           |
| episode_types  | ✓         | mid_season_premiere | Set to standard, series_premiere, season_premiere, mid_season_finale, mid_season_premiere, season_finale, or series_finale. |

### Images

Trakt can return images by appending `?extended=images` to most URLs. This will return all images for a movie, show, season, episode, or person. Images are returned in an `images` object with keys for each image type. Each image type is an array of image URLs, but only 1 image URL will be returned for now. This is just future proofing.

> ☣️ **IMPORTANT**
>
> Please cache all images! All images are required to be cached in your app or server and not loaded directly from our CDN. Hotlinking images is not allowed and will be blocked.

> **NOTE**
>
> All images are returned in WebP format for reduced file size, at the same image quality. You'll also need to prepend the `https://` prefix to all image URLs.
