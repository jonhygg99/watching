# Watching - Trakt.tv Client for Flutter

## Project Overview

Watching is a Flutter mobile application that serves as a client for the Trakt.tv API, allowing users to track TV shows and movies. The app provides features for discovering new content, managing watchlists, viewing detailed show information, and tracking viewing progress.

### Key Features

1. **User Authentication** - OAuth 2.0 integration with Trakt.tv
2. **Discover** - Browse trending, popular, and recommended shows
3. **Watchlist** - Manage and track shows/movies you want to watch
4. **Show Details** - Comprehensive information about TV shows including seasons, episodes, cast, and related content
5. **My Shows** - Track your currently watched shows and upcoming episodes
6. **Search** - Find shows and movies by title or other criteria
7. **Settings** - Configure user preferences like country for translations

### Main Technologies

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod with Hooks
- **Architecture**: Clean Architecture with separation of concerns
- **API**: Trakt.tv REST API
- **Authentication**: OAuth 2.0
- **Local Storage**: SharedPreferences
- **Networking**: http package
- **UI Components**: Material Design with custom widgets
- **Testing**: flutter_test with mockito

## Project Structure

```
lib/
├── api/                    # API clients and services
│   └── trakt/             # Trakt.tv API implementation
├── discover/              # Discover/Explore feature
├── features/              # Feature-specific modules
│   ├── myshows/          # "My Shows" functionality
│   └── watchlist/        # Watchlist management
├── helpers/               # Utility functions and helpers
├── login/                 # Authentication flow
├── myshows/              # My Shows UI components
├── providers/            # Global Riverpod providers
├── search/               # Search functionality
├── settings/             # Settings UI
├── shared/               # Shared components and constants
├── show_details/         # Show details pages and components
├── watchlist/            # Watchlist UI components
├── country_list.dart     # Country code mappings
├── main.dart             # App entry point
├── splash_wrapper.dart   # Authentication wrapper
└── youtube_player_dialog.dart # YouTube player component

test/
├── api/                  # API client tests
├── features/             # Feature-specific tests
├── search/               # Search feature tests
└── shared/               # Shared component tests

docs/
├── sistema-autenticacion.md # Authentication documentation
├── vision-general.md        # Overall project vision
└── watchlist.md             # Watchlist feature documentation
```

## Development Guidelines

### Code Organization

1. **Follow Clean Architecture principles** with clear separation between data, domain, and presentation layers
2. **Use Riverpod for state management** with generated providers for better performance
3. **Organize code by features** in the `features/` directory
4. **Keep UI components in respective feature directories** (e.g., `watchlist/`, `show_details/`)
5. **Use generated code** for Riverpod providers and Freezed classes

### State Management

1. **Use Riverpod providers** for global state management
2. **Prefer `HookConsumerWidget`** for widget-level state when using hooks
3. **Use `StateNotifier`** for complex state logic
4. **Use `FutureProvider`** for asynchronous data loading
5. **Use `AsyncNotifierProvider`** for complex async state management

### API Integration

1. **All API integrations go through the `TraktApi` class**
2. **Use mixins** to organize API endpoints by domain (shows, users, history, etc.)
3. **Handle authentication tokens** automatically in the base API class
4. **Implement proper error handling** with meaningful error messages
5. **Cache responses when appropriate** to improve performance

### UI/UX Principles

1. **Use Material Design components** with consistent styling
2. **Implement responsive layouts** using LayoutBuilder or MediaQuery
3. **Provide loading states** with spinners or skeleton screens
4. **Handle errors gracefully** with user-friendly messages
5. **Implement pull-to-refresh** for list-based views
6. **Use consistent navigation patterns** throughout the app

### Testing

1. **Write unit tests** for business logic and services
2. **Use mockito for mocking dependencies** in tests
3. **Test API integrations** with mock responses
4. **Write widget tests** for complex UI components
5. **Use golden tests** for visual regression testing when appropriate

## Building and Running

### Prerequisites

1. Flutter SDK (version as specified in pubspec.yaml)
2. Dart SDK
3. Android Studio or Xcode for mobile development
4. Trakt.tv API credentials (client ID and secret)

### Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Create a `.env` file with your Trakt.tv API credentials:
   ```
   TRAKT_CLIENT_ID=your_client_id
   TRAKT_CLIENT_SECRET=your_client_secret
   TRAKT_REDIRECT_URI=your_redirect_uri
   ```
4. Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`

### Running the App

```bash
# Run on a connected device or emulator
flutter run

# Run on a specific platform
flutter run -d android
flutter run -d ios

# Run in release mode
flutter run --release
```

### Building

```bash
# Build APK for Android
flutter build apk

# Build appbundle for Android
flutter build appbundle

# Build IPA for iOS
flutter build ios
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test_file.dart
```

## Development Workflow

1. **Create a feature branch** from main for new features
2. **Follow the existing code style** and conventions
3. **Write tests** for new functionality
4. **Run existing tests** to ensure no regressions
5. **Update documentation** when making significant changes
6. **Run code generation** when adding new Riverpod providers
7. **Test on both Android and iOS** when possible
8. **Create a pull request** with a clear description of changes

## Key Components

### Authentication System

- Located in `lib/login/` and `lib/providers/auth_provider.dart`
- Uses OAuth 2.0 authorization code flow with Trakt.tv
- Manages access and refresh tokens with automatic renewal
- Provides global authentication state through Riverpod

### Watchlist Management

- Core logic in `lib/features/watchlist/`
- Uses a `StateNotifier` for complex state management
- Implements caching for better performance
- Supports both shows and movies
- Provides episode tracking functionality

### Show Details

- Located in `lib/show_details/`
- Comprehensive show information display
- Season and episode browsing
- Cast and crew information
- Related shows recommendations
- Video trailers integration

### My Shows

- Located in `lib/myshows/` and `lib/features/myshows/`
- Tracks currently watched shows
- Displays upcoming episodes
- Shows waiting and ended shows
- Integrates with calendar API for episode scheduling

### Discover

- Located in `lib/discover/`
- Multiple carousels for different show categories
- Trending, popular, and recommended content
- "View more" functionality for each category

### Search

- Located in `lib/search/`
- Search shows and movies by title
- Filter by type (show/movie)
- Trending content when search is empty

## Error Handling

1. **Network errors** are caught and displayed to users
2. **API errors** are parsed and shown with meaningful messages
3. **Authentication errors** trigger re-authentication flows
4. **Local errors** are handled gracefully with fallbacks
5. **Error boundaries** are implemented to prevent app crashes

## Performance Considerations

1. **Lazy loading** for large lists and data sets
2. **Caching** of API responses to reduce network calls
3. **Pagination** for large data sets
4. **Image caching** for better loading performance
5. **Debouncing** for search and filter operations
6. **Efficient state updates** to minimize rebuilds

## Internationalization

1. **Country selection** for content translations
2. **Language-specific content** from Trakt.tv API
3. **Country flags** displayed with Unicode characters
4. **Localized content** based on user's country preference

## Future Improvements

1. **Implement comprehensive testing** for all features
2. **Add more analytics and logging**
3. **Improve offline functionality**
4. **Add more personalization options**
5. **Implement push notifications** for upcoming episodes
6. **Add social features** like sharing and comments