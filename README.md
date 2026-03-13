# Developer Note

Codebase generated from NOWA AI. It was not working. Hence some refinements are there to make first init on repo-it was debuggable build.
- I had not worked since months. Yet I am adaptable. 
- I encountered critical issue with the android build configuration on hot codebase exported from NOWA AI. to completely resolve it I deleted android folder and fired flutter create command on project root.
- worked on article cards. the elements were overflowing. so I hard coded height values and used double.infinity on article image so it looks satisfying. 
- The current scenario keeps the favorites same for any user. I spent hours trying to debug favorites issue. I had to stash the changes and submit code to github. It still needs work.




# Mini News Intelligence

A Mini News Intelligence app built with Flutter, Riverpod and Hive. The app demonstrates a clean architecture, Riverpod state management, API integration with caching & local persistence, and robust error handling.

## Features
- Simple authentication flow (mocked) with persisted login state using Hive.
- News Feed with category-based listing, pagination, and pull-to-refresh.
- Search articles with debounced queries and pagination.
- Article detail view with Save as Favorite, Open in Browser.
- Favorites screen with offline persistence and swipe-to-remove.
- Local caching of pages and offline fallback.
- State management with Riverpod, local storage with Hive, network using http.

## Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK compatible (see pubspec)
- Optional: News API key (e.g., https://newsapi.org). The app defaults to empty API_KEY which will need to be provided.

## Installation

1. Clone the repository:
    git clone <repo-url>
    cd mini_news_intelligence

2. Get dependencies:
    flutter pub get

3. (Optional) If you wish to generate Hive adapters via build_runner:
    flutter pub run build_runner build --delete-conflicting-outputs

4. Provide API key:
   - Option A: Run with dart define:
        flutter run --dart-define=API_KEY=your_api_key --dart-define=API_BASE_URL=https://newsapi.org/v2
   - Option B: Modify `lib/src/core/constants.dart` to set the API_KEY constant (not recommended).

## Running
- Run on connected device or emulator:
    flutter run --dart-define=API_KEY=YOUR_API_KEY

## Configuration / Environment Variables
- API_BASE_URL: Base URL for news API (default: https://newsapi.org/v2)
- API_KEY: Your news API key.
- DEFAULT_PAGE_SIZE: Number of articles per page.

You can pass these via --dart-define or set in your environment for development.

## Architecture Overview

The project follows a Clean Architecture layered approach:

- lib/src/features: Feature-based modules (auth, news) containing UI and provider logic.
- lib/src/data: Data layer (models, remote & local datasources, repository implementations).
- lib/src/domain: Domain entities and repository interfaces.
- lib/src/core: App-wide constants, network, theme, routes.
- lib/src/shared: Reusable widgets and utilities.
- lib/src/providers.dart: Common provider wiring for dependency injection.

Why Riverpod?
- Riverpod provides compile-time safety, testability, and simplicity. StateNotifier combined with Riverpod offers a clean mutable state approach.

Local Persistence (Hive)
- Hive boxes:
    - 'favorites' stores ArticleModel objects (saved as Hive objects).
    - 'auth' stores UserModel under key 'user'.
    - 'cache' stores lightweight page caches as Map.
- Hive adapters are implemented manually in the models to avoid build_runner dependency. If you modify models, ensure TypeAdapters are updated.

API Integration
- The app assumes a NewsAPI.org-compatible API. It constructs calls for:
    - GET /top-headlines?category={category}&page={page}&pageSize={pageSize}
    - GET /everything?q={query}&page={page}&pageSize={pageSize}
- Rate limiting: News APIs often limit requests. Use caching and avoid excessive queries.

Folder Structure
- lib/
    - main.dart: App entrypoint and Hive initialization
    - src/
        - core/: constants, network, app theme, routes
        - data/: models, datasources (remote/local), repositories
        - domain/: entities
        - features/: auth and news feature modules with UI and providers
        - shared/: reusable widgets and utilities
        - config/: logger, etc.

How to add features
1. Create new feature folder under src/features.
2. Add UI screens and Riverpod providers.
3. Register any new repositories/providers in src/providers.dart to enable overrides in tests.

Testing
- Basic widget test included demonstrating app boots and login UI.
- Providers are designed to be easy to override in tests via ProviderScope.overrides.

Troubleshooting
- Hive issues: If you modify adapters, delete existing app data or change typeIds carefully.
- API errors: Ensure API_KEY is valid and API_BASE_URL is correct.
- Connectivity: The app gracefully falls back to cached content when offline.

Notes & Decisions
- Manual Hive adapters were implemented to avoid build_runner requirement for immediate run.
- Auth is mocked: any non-empty credentials will succeed and be persisted locally.
- The NewsRepository synchronizes favorites from local storage to remote-fetched lists.
- Error handling: Network, API, and parsing exceptions are translated into user-friendly messages and displayed via SnackBar or ErrorRetryWidget.

Assets
- Placeholder/fallback images use Unsplash URLs and are referenced directly.

License
- MIT License

If you want a production-ready deployment, consider:
- Using secure storage for tokens
- Implementing real authentication
- Offloading heavy image loading and caching
- Improving pagination with cursor-based APIs where available
- Adding analytics/logging integrations
