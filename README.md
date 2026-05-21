# homeres

A mobile app connecting homeowners with verified repair technicians.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Running Tests](#running-tests)
- [Contributing](#contributing)
- [License](#license)

## Features

### For Homeowners

- Browse and search for services
- View technician profiles, ratings, and reviews
- Book services and schedule appointments
- Track service progress in real-time
- Manage booking history
- Leave reviews and ratings for completed services
- Save favorite technicians
- Secure in-app payments
- Profile management

### For Technicians

- Receive job requests
- Manage schedule and availability
- View earnings and payment history
- Update profile and skills
- Accept/decline job requests
- View job details and location
- Profile verification process

### For Administrators

- Admin dashboard with analytics
- Manage users (homeowners and technicians)
- Manage services and categories
- View system analytics and reports
- Content moderation

## Architecture

This project follows a clean architecture pattern with Riverpod for state management:

```
lib/
├── core/               # Core utilities, constants, extensions
├── data/               # Data layer (models, datasources, repositories)
├── domain/             # Domain layer (entities, repositories, usecases)
├── di/                 # Dependency injection
├── features/           # Feature-specific widgets and providers
├── presentation/       # UI layer (screens, providers, widgets)
└── routing/            # App routing configuration
```

### Key Technologies

- **State Management**: Flutter Riverpod
- **Dependency Injection**: Custom injection container
- **Navigation**: GoRouter
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Local Storage**: Shared Preferences + Secure Storage
- **Maps**: Flutter Map + OSM Plugin
- **Animations**: Flutter Animate
- **Forms**: Custom form validators

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5
- Dart SDK ^3.11.5
- Firebase account and project configured
- Android Studio / VS Code with Flutter & Dart plugins
- (Optional) iOS development setup for macOS users

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Athore07/homeres-stable1.git
   cd homeres
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at <https://console.firebase.google.com/>
   - Add Android and/or iOS apps to your Firebase project
   - Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS)
   - Place the files in the appropriate directories:
     - Android: `android/app/google-services.json`

   - Enable required Firebase services:
     - Authentication (Email/Password, Phone)
     - Cloud Firestore
     - Firebase Storage

4. **Run the app**

   ```bash
   flutter run
   ```

### Environment Variables

Create a `.env` file in the root directory if needed for additional configuration.

## Project Structure

### Core

- `constants/` - App constants, API endpoints, colors
- `errors/` - Custom exceptions and failures
- `extensions/` - Helper extensions on built-in types
- `mixins/` - Reusable mixins
- `network/` - Network connectivity utilities
- `seed/` - Initial data seeding scripts
- `services/` - Core services (Firebase, secure storage)
- `theme/` - App theming (light/dark modes)
- `utils/` - Utility functions (date formatting, device info, validators)

### Data

- `models/` - Data models with JSON serialization
- `datasources/` - Local and remote data sources
- `repositories/` - Repository implementations

### Domain

- `entities/` - Business logic entities
- `repositories/` - Abstract repository contracts
- `usecases/` - Application business logic

### Dependency Injection

- `injection_container.dart` - Service locator setup

### Features

- Feature-specific screens and providers

### Presentation

- `providers/` - State management providers (Riverpod)
- `screens/` - UI screens organized by user role
- `widgets/` - Reusable UI components

## Dependencies

### Core Dependencies

- `flutter_riverpod: ^3.3.1` - State management
- `go_router: ^17.2.2` - Routing
- `firebase_core: ^4.7.0` - Firebase core
- `firebase_auth: ^6.4.0` - Authentication
- `cloud_firestore: ^6.3.0` - Database
- `firebase_storage: ^13.3.0` - File storage
- `flutter_map: ^6.1.0` + `latlong2: ^0.9.0` + `flutter_osm_plugin: ^1.4.3` - Mapping
- `flutter_animate: ^4.5.2` - Animations
- `google_fonts: ^8.1.0` - Typography
- `uuid: ^4.5.0` - Unique ID generation
- `url_launcher: ^6.3.2` - Launch URLs
- `image_picker: ^1.2.2` - Image selection
- `intl: ^0.20.2` - Internationalization
- `shared_preferences: ^2.5.5` + `flutter_secure_storage: ^10.0.0` - Local storage
- `local_auth: ^3.0.1` - Biometric authentication
- `device_info_plus: ^12.4.0` + `connectivity_plus: ^7.1.1` + `geolocator: ^14.0.2` + `geocoding: ^4.0.0` - Device & location services
- `dio: ^5.9.2` - HTTP client
- `shimmer: ^3.0.0` - Loading placeholders
- `equatable: ^2.0.8` - Value object comparison
- `package_info_plus: ^9.0.1` - App version info

### Dev Dependencies

- `flutter_test` - Flutter testing framework
- `flutter_lints: ^6.0.0` - Linting rules
- `build_runner: ^2.4.0` - Code generation
- `riverpod_generator: ^4.0.2` - Riverpod code generation

## Running Tests

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widgets/
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

## Building for Release

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to:

- Follow the existing code style
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- OpenStreetMap contributors for map data
- All contributors to the open-source packages used in this project

---

*Built with ❤️ using Flutter*
