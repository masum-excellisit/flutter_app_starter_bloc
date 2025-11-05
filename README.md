# Flutter App Starter (BLoC + GoRouter)

A production-ready Flutter starter that demonstrates clean architecture, modular features, reusable CRUD tooling, offline-first caching, and navigation powered by GoRouter.

## 🎯 Highlights

- Clean Architecture separating core utilities from feature modules
- Universal CRUD stack with a reusable `CrudBloc`, generic repository contract, and pagination helpers
- GoRouter navigation plus optional bottom navigation driven by feature toggles
- Network & Storage using Dio, shared preferences, secure storage, and Sqflite for offline lists
- Feature Modules for auth flows, profile management, and a fully working posts module backed by DummyJSON
- Consistent UI Shell via a shared `AppScaffold` that injects app bars, FABs, and the reusable bottom navigation bar
- Extensive Utilities covering theming, validation, helpers, and storage abstraction

## 📦 Available Modules

- Splash – App bootstrapping & first-run logic
- Login / Register – Starter auth flows built with forms and validation
- Profile / Edit Profile – REST-backed profile editing with storage-backed logout
- Posts – Universal CRUD example (list, search, create, edit, delete) using pagination, offline cache, and reusable widgets

## 📁 Current Project Structure

```
lib/
├── app_router.dart
├── core/
│   ├── bloc/
│   │   └── paginated_crud_bloc.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── domain/
│   │   └── crud_repository.dart
│   ├── models/
│   │   └── paginated_result.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_response.dart
│   │   └── api_urls.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── app_helpers.dart
│   │   ├── storage_service.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_bottom_navigation_bar.dart
│       ├── app_scaffold.dart
│       ├── paginated_list_view.dart
│       └── search_input.dart
├── features/
│   ├── edit_profile/
│   ├── login/
│   ├── posts/
│   │   ├── api/
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/
│   ├── register/
│   └── splash/
├── injection_container.dart
└── main.dart
```

## ⚙️ Configuration

- API endpoints: update `lib/core/network/api_urls.dart` or `AppConstants.baseUrl`
- Feature toggles: switch features such as the bottom navigation via `AppConstants.enableBottomNavigation`
- Dependencies: install with `flutter pub get`

### Auth (Login/Register) configuration

- Endpoints used (DummyJSON):
  - Login: `POST /auth/login`
  - Register: `POST /users/add`
- Tokens are stored using `StorageService`:
  - Access token key: `AppConstants.accessTokenKey`
  - Refresh token key: `AppConstants.refreshTokenKey`
- After successful login, a token is added to all requests via `ApiClient` interceptor (Bearer token header).
- Logout clears all persisted state and secure tokens and navigates to `login`.

## 🚀 Getting Started

1. Clone the repo

```bash
git clone <repository-url>
cd flutter_app_starter_bloc
```

2. Install packages

```bash
flutter pub get
```

3. Run locally

```bash
flutter run
```

## ▶️ Try the flows

- Splash → Login/Register → Profile
- Posts list with search, create, edit, delete
- Toggle bottom nav on/off via `AppConstants.enableBottomNavigation`

## 🗺️ Default routes (see `app_router.dart`)

- `/splash`
- `/login`
- `/register`
- `/profile`
- `/edit_profile`
- `/posts`

## 🧩 Reusable CRUD Workflow

The Posts feature showcases the generic CRUD stack that can be reused for any entity:

1. Repository contract: implement `CrudRepository<T, CreatePayload, UpdatePayload, Id>`
2. Bloc: extend `CrudBloc` and provide `idSelector`, optional `updateMerger`, and page size
3. Local cache: implement cache methods (e.g., via Sqflite) to support offline hydration
4. UI: compose screens with `AppScaffold`, `PaginatedListView`, and custom widgets/forms
5. Routing: register the module in `app_router.dart` using GoRouter

The module automatically supports pagination, pull-to-refresh, debounced search, inline notifications, and offline fallbacks.

## 🧭 Navigation

- Application routes are registered in `app_router.dart`
- `AppScaffold` consumes GoRouter to keep the bottom navigation bar in sync with the current location
- Disable the bottom navigation (for kiosk flows, auth screens, etc.) by toggling `AppConstants.enableBottomNavigation`
- Use `context.goNamed('routeName')` or `context.pushNamed('routeName')` within features

### Adding a bottom tab

1. Open `lib/core/widgets/app_bottom_navigation_bar.dart`
2. Append a new `_BottomNavItem(label, icon, path)` to `_navItems`
3. Register a matching GoRoute in `app_router.dart`
4. Use `AppScaffold` in your screen to get the nav automatically

## 📥 Offline Experience

- Posts lists are cached in Sqflite (`PostsLocalDataSource`) so users can browse the last fetched data when offline
- `CrudBloc` automatically surfaces offline state and reuses cached data on failures

## 🛠️ Development Commands

```bash
# format & analyze
flutter format .
flutter analyze

# run tests
flutter test

# codegen (when needed)
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🧪 Auth Flow Details

- The login/register modules use standard forms and `Validators` from `core/utils/validators.dart`.
- On successful login, tokens are saved via `StorageService.saveTokens()`; `ApiClient` adds `Authorization: Bearer <token>`.
- `ProfileBloc` checks for 401 responses to redirect back to `login`.
- `ProfileView` exposes a Logout button that calls `StorageService.clearAllData()` then `context.goNamed('login')`.

## 🏁 New Project Setup (reuse this starter)

1. Copy the `lib/` folder structure (or cherry-pick features you want).
2. Ensure `pubspec.yaml` contains the required dependencies:
   - `flutter_bloc`, `go_router`, `dio`, `shared_preferences`, `flutter_secure_storage`, `sqflite`, `path`, `equatable`, `intl`
3. Update API endpoints in `core/network/api_urls.dart` and any constants in `core/constants/app_constants.dart`.
4. Keep `main.dart` bootstrapping (calls `StorageService.init()` and wires `MaterialApp.router` with `AppRouter.router`).
5. Register routes for your modules in `app_router.dart`.
6. Build features following the Posts pattern: API → Repository → Bloc → Screens/Widgets. Use `CrudBloc` for fast CRUD.
7. If you need offline lists, create a simple local data source like `PostsLocalDataSource` with Sqflite.
8. Wrap screens with `AppScaffold` to get the shared bottom navigation (toggle via `enableBottomNavigation`).
9. For auth: wire your login/register APIs, save tokens, and guard routes in your blocs/screens as shown in Profile.
10. Run and verify:

```bash
flutter clean
flutter pub get
flutter run
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit (`git commit -m "Add my feature"`)
4. Push (`git push origin feature/my-feature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

Happy building! 🚀
