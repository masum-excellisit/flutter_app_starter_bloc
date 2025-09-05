# flutter_app_starter_bloc

# Flutter App Starter with Clean Architecture

A comprehensive Flutter app starter template featuring clean architecture, BLoC pattern, Go Router, and ready-to-use essential functionalities.

## 🎯 Features

### ✨ Core Features

- **Clean Architecture** - Domain, Data, and Presentation layers
- **BLoC Pattern** - State management with flutter_bloc
- **Go Router** - Declarative routing
- **Dependency Injection** - Using GetIt
- **API Integration** - Dio HTTP client with interceptors
- **Local Storage** - SharedPreferences & Flutter Secure Storage
- **Error Handling** - Comprehensive error handling with Either pattern
- **Form Validation** - Custom validators for forms
- **Theming** - Light/Dark theme support

### 📱 Ready-to-use Screens

- **Splash Screen** - With animations and auth check
- **Login Screen** - Email/username and password authentication
- **Register Screen** - User registration with validation
- **Home Screen** - Dashboard with navigation
- **Profile Screen** - User profile management
- **Product Listing** - CRUD operations example

### 🏗️ Architecture Components

- **Entities** - Core business objects
- **Use Cases** - Business logic
- **Repositories** - Data access abstraction
- **Data Sources** - Remote and local data sources
- **Models** - JSON serialization
- **BLoC** - State management
- **Widgets** - Reusable UI components

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── app_strings.dart
│   │   └── app_styles.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── app_helpers.dart
│   │   ├── storage_service.dart
│   │   └── validators.dart
│   └── widgets/
│       └── common_widgets.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   ├── profile/
│   ├── products/
│   └── splash/
├── app_router.dart
├── injection_container.dart
└── main.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.4)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd flutter_app_starter_bloc
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **API Configuration**
   Update the base URL in `lib/core/constants/app_constants.dart`:

   ```dart
   static const String baseUrl = 'https://your-api-url.com';
   ```

2. **App Configuration**
   Update app details in `lib/core/constants/app_constants.dart` and `pubspec.yaml`.

## 📚 Usage Examples

### Adding a New Feature

1. **Create feature folder structure**:

   ```
   lib/features/my_feature/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── presentation/
       ├── bloc/
       ├── pages/
       └── widgets/
   ```

2. **Create entity**:

   ```dart
   class MyEntity extends Equatable {
     final int id;
     final String name;

     const MyEntity({required this.id, required this.name});

     @override
     List<Object> get props => [id, name];
   }
   ```

3. **Create repository interface**:

   ```dart
   abstract class MyRepository {
     Future<Either<Failure, List<MyEntity>>> getItems();
   }
   ```

4. **Create use case**:

   ```dart
   class GetItemsUseCase {
     final MyRepository repository;
     GetItemsUseCase(this.repository);

     Future<Either<Failure, List<MyEntity>>> call() async {
       return await repository.getItems();
     }
   }
   ```

5. **Register dependencies** in `injection_container.dart`

### Using BLoC

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetItemsUseCase getItemsUseCase;

  MyBloc({required this.getItemsUseCase}) : super(MyInitial()) {
    on<LoadItems>(_onLoadItems);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<MyState> emit) async {
    emit(MyLoading());
    final result = await getItemsUseCase();
    result.fold(
      (failure) => emit(MyError(message: failure.message)),
      (items) => emit(MyLoaded(items: items)),
    );
  }
}
```

### Navigation with Go Router

```dart
// Navigate to a page
context.go('/home');
context.push('/profile');

// Navigate with parameters
context.go('/product/${productId}');

// Replace current route
context.go('/login');
```

### API Integration

```dart
class MyRemoteDataSource {
  final ApiClient apiClient;
  MyRemoteDataSource({required this.apiClient});

  Future<List<MyModel>> getItems() async {
    final response = await apiClient.get('/items');
    return (response.data as List)
        .map((json) => MyModel.fromJson(json))
        .toList();
  }
}
```

### Local Storage

```dart
// Simple storage
await StorageService.setString('key', 'value');
final value = StorageService.getString('key');

// Secure storage
await StorageService.setSecureString('token', 'secure_token');
final token = await StorageService.getSecureString('token');
```

## 🎨 Customization

### Themes

Modify `lib/core/theme/app_theme.dart` to customize colors, fonts, and component themes.

### Colors

Update `lib/core/constants/app_styles.dart` to change the color palette:

```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFFFF9800);
  // Add more colors...
}
```

### Strings

Add/modify strings in `lib/core/constants/app_strings.dart` for easy localization.

## 🔧 Development

### Code Generation

If you need JSON serialization with code generation:

```bash
flutter packages pub run build_runner build
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Linting

```bash
flutter analyze
```

## 📦 Dependencies

### Main Dependencies

- `flutter_bloc` - State management
- `go_router` - Routing
- `dio` - HTTP client
- `get_it` - Dependency injection
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Secure storage
- `equatable` - Value equality
- `dartz` - Functional programming

### Dev Dependencies

- `flutter_test` - Testing framework
- `flutter_lints` - Linting rules
- `build_runner` - Code generation
- `json_serializable` - JSON serialization

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The framework
- [BLoC Library](https://bloclibrary.dev/) - State management
- [DummyJSON](https://dummyjson.com/) - Sample API for testing

## 📞 Support

If you have any questions or need help with the starter template:

1. Check the [documentation](docs/)
2. Open an issue on GitHub
3. Start a discussion in the repository

---

**Happy Coding!** 🚀

Built with ❤️ using Flutter
