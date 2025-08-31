## Functional Requirements for the Watching App

The Watching app will serve as a TV show and movie tracker, integrating with the Trakt API to provide users with a comprehensive experience. Below are the concise functional requirements categorized by the main features of the application.

---

### 1. Integration with Trakt API

- The app must integrate seamlessly with the **Trakt API** to fetch data related to TV shows and movies.

---

### 2. Pages and Features

#### 2.1 Discover Page

- Display a list of TV shows and movies categorized as:
  - Trending
  - Popular
  - Most favorited in a week
  - Most collected in a week
  - Most played in a week
  - Most watched in a week
  - Most anticipated
- Include a **story feature** that showcases fanart photos of trending shows/movies.
- Provide a button to redirect users to a TikTok-like page featuring clips and trailers of trending shows/movies.
- Each item in the list must link to the **Show/Movie Details** page.

#### 2.2 Show/Movie Details Page

- Display detailed information about the selected show/movie.
- Include a widget showing the **current episode** for TV shows.
- Provide a button to check episode information.
- Include a link to the **Seasons Details** page for the current season.

#### 2.3 Seasons Details Page

- List episodes of the current season, with options to mark episodes as watched or not.
- Include buttons to navigate to **previous** and **next seasons**.
- Provide a button to link to another season.

#### 2.4 Watchlist Page

- Display a list of shows/movies that the user intends to watch.
- For TV shows, indicate the **current episode** the user is on.
- Filter shows by the **last watched episode**.

#### 2.5 Calendar Page

- Show upcoming episodes from the watchlist, indicating:
  - Days left until the next episode airs
  - Status of shows (waiting for the next season or ended)

#### 2.6 Search Page

- Default view should display trending shows/movies.
- Include a **search bar** for users to find specific shows/movies.

#### 2.7 Settings Page

- Allow users to change:
  - Country
  - Language
  - Theme
- Provide an option to **log out** of the app.

---
