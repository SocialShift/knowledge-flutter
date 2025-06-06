# Knowledge Flutter

**Knowledge Flutter** is a cross-platform mobile application built using Flutter. It serves as a foundational project to demonstrate the capabilities of Flutter in building responsive and interactive applications. This project is ideal for developers looking to understand the basics of Flutter app development and serves as a starting point for more complex applications.

## Features

* Cross-platform support: Android, iOS, Web, Windows, macOS, and Linux.
* Modular code structure for scalability.
* Responsive UI design.
* Integration with Flutter's latest features and best practices.
* Ready-to-use templates and components.

## Technologies Used

* [Flutter](https://flutter.dev/)
* [Dart](https://dart.dev/)
* [Material Design](https://material.io/design)
* [Flutter Widgets](https://docs.flutter.dev/development/ui/widgets)
* [Provider](https://pub.dev/packages/provider) for state management (if used)

## Recent Fixes

### Authentication State Management Issue (Fixed)

**Issue**: After logging out and immediately trying to access the signup page, users were getting redirected to the login page with a "you are already logged in" behavior, even though they had just logged out.

**Root Cause**: 
- Race condition in authentication state management during logout
- Router redirect logic wasn't properly handling the transition from authenticated to unauthenticated state
- Session storage and state wasn't being completely cleared during logout

**Solutions Implemented**:

1. **Enhanced Logout Process** (`lib/data/providers/auth_provider.dart`):
   - Added session timer cancellation before logout
   - Improved error handling to always clear local state even if API fails
   - Added provider invalidation to clear cached auth state
   - Added debug logging to track logout process

2. **Improved Router Logic** (`lib/presentation/navigation/router.dart`):
   - Added explicit check for `unauthenticated` state to allow access to auth routes after logout
   - Better handling of state transitions
   - Added comprehensive debug logging to track redirect decisions

3. **Robust Auth Repository** (`lib/data/repositories/auth_repository.dart`):
   - Modified logout to always clear storage in `finally` block
   - Ensures logout succeeds locally even if API call fails

4. **Enhanced User Experience** (`lib/presentation/screens/profile/profile_screen.dart`):
   - Added loading indicators during logout
   - Better error handling and user feedback
   - Proper navigation stack clearing

**Testing**:
To verify the fix:
1. Log in to the app
2. Log out from the profile screen
3. Immediately try to access the signup page
4. The signup page should load without any redirects

The debug logs will show the authentication state transitions and router decisions.

## Key Features

- 🎯 **Timeline**: Historical events and stories
- 📚 **Stories**: Rich multimedia learning content
- 🎮 **Games**: Interactive learning games
- 🏆 **Quizzes**: Knowledge assessment tools
- 📊 **Leaderboard**: Social learning features
- 🔔 **Notifications**: Daily learning reminders
- 🌙 **Dark Mode**: System-aware theming

## Architecture

Built using Flutter best practices:
- **State Management**: Riverpod with code generation
- **Navigation**: GoRouter with declarative routing
- **Backend**: Supabase for authentication and data
- **UI**: Material Design with custom theming
- **Networking**: Dio with interceptors for API calls
- **Local Storage**: Flutter Secure Storage for session management

## Getting Started

### Prerequisites

* Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
* Dart SDK (usually comes with Flutter)
* An IDE like [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)
* Emulator or physical device for testing

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/SocialShift/knowledge-flutter.git
   cd knowledge-flutter
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   Create a `.env` file in the root directory with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Generate code:**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the application:**([Medium][2])

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                 # Core functionalities (themes, config, utils)
├── data/                 # Data layer (models, repositories, providers)
├── presentation/         # UI layer (screens, widgets, navigation)
└── main.dart            # Entry point
```

## Usage

Upon launching the application:

* Navigate through the various screens to explore the app's features.
* Interact with UI components to understand their behavior.
* Use this project as a reference for building your own Flutter applications.([GitHub][3])

## Contributing

Contributions are welcome! To contribute:

1. **Fork the repository**
2. **Create a new branch:**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3\. **Make your changes**
4\. **Commit your changes:**

```bash
git commit -m "Add your message here"
```

5\. **Push to your forked repository:**

```bash
git push origin feature/your-feature-name
```

6\. **Create a Pull Request**([Medium][2])

Please ensure your code adheres to the project's coding standards and includes relevant tests.

## License

This project is licensed under the MIT License.

