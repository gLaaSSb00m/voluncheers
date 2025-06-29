# VolunCheers - Volunteer Management App

Welcome to **VolunCheers**, a Flutter-based mobile application designed to help users discover and manage volunteering opportunities. This app, built using Flutter and developed in Android Studio, provides an intuitive interface for signing up, browsing opportunities, tracking volunteering history, and managing profiles.

**Last Updated**: Monday, May 26, 2025, at 06:45 AM (+06)

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)
- [Navigation Flow](#navigation-flow)
- [Technologies Used](#technologies-used)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Installing Flutter](#installing-flutter)
  - [Installing Android Studio](#installing-android-studio)
  - [Setting Up the Project](#setting-up-the-project)
- [Dependencies](#dependencies)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [Authors and Acknowledgments](#authors-and-acknowledgments)
- [Contact Information](#contact-information)
- [Changelog](#changelog)
- [License](#license)

## Project Overview
VolunCheers is a volunteer management app that allows users to:
- Sign up and log in with email verification.
- Browse and swipe through volunteering opportunities using a Tinder-like interface.
- View and manage their profile, including personal details, interests, and volunteering history.
- Save and manage favorite opportunities.
- Navigate seamlessly between home, favorites, and profile screens with a custom bottom navigation bar.

The app integrates with Supabase for authentication and database management, and is built using Flutter for a cross-platform experience.

## Features
- **User Authentication**: Signup, login, and logout with email verification.
- **Opportunity Browsing**: Swipe-based interface to browse volunteering opportunities.
- **Profile Management**: Edit personal details (name, phone, email, gender, interests).
- **Volunteering History**: Track past volunteering activities (mock data currently).
- **Favorites**: Save and manage favorite opportunities.
- **Responsive Design**: Consistent UI with dark green and golden theme, using `AppColors`.

## Screenshots


- **Onboarding Screen**: [onboarding.png](screenshots/onboarding.png)
- **Home Screen (Swipe Cards)**: [home.png](assets/screenshots/home.png)
- **Opportunity Details Screen**: [opportunity_details.png](assets/screenshots/opportunity_details.png)
- **Favorites Screen**: [favorites.png](assets/screenshots/favorites.png)
- **Signup Success Screen**: [signup_success.png](assets/screenshots/signup_success.png)

*Note*: To add screenshots, capture images from the emulator or device, save them in `assets/screenshots/`, and update the links above.

## Project Structure
```
lib
├─ main.dart              # Entry point of the application
├─ screens                # Contains all screen widgets
│  ├─ confirmation_screen.dart     # OTP verification screen
│  ├─ favorites_screen.dart        # Favorites list screen
│  ├─ home_screen.dart            # Main screen with swipe cards
│  ├─ login_screen.dart           # Login screen
│  ├─ onboarding_screen.dart      # Initial onboarding screen
│  ├─ opportunity_details_screen.dart # Opportunity details screen
│  ├─ personal_details_screen.dart    # Personal details input screen
│  ├─ signup_screen.dart            # Signup screen
│  └─ signup_success_screen.dart    # Signup success screen
├─ services               # Contains service logic
│  └─ auth_service.dart   # Authentication service using Supabase
├─ utils                  # Utility files
│  ├─ constants.dart      # App-wide constants (e.g., colors)
│  ├─ progress_indicator.dart # Custom progress indicator widget
│  └─ supabase_config.dart # Supabase client configuration
└─ widgets                # Reusable widgets
   └─ custom_bottom_nav.dart # Custom bottom navigation bar
```

## Navigation Flow
The app follows this navigation structure:

1. **Onboarding Screen (`onboarding_screen.dart`)**:
   - Initial screen with "Get Started" (navigates to `SignupScreen`) and "Already have an account?" (navigates to `LoginScreen`) options.

2. **Signup Screen (`signup_screen.dart`)**:
   - Collects name, email, and password; navigates to `PersonalDetailsScreen` after submission.

3. **Personal Details Screen (`personal_details_screen.dart`)**:
   - Gathers DOB, phone, gender, and interests; navigates to `ConfirmationScreen` after submission.

4. **Confirmation Screen (`confirmation_screen.dart`)**:
   - OTP verification for phone; navigates to `SignupSuccessScreen` on success.

5. **Signup Success Screen (`signup_success_screen.dart`)**:
   - Displays success message with confetti animation; navigates to `HomeScreen` via `pushReplacement`.

6. **Login Screen (`login_screen.dart`)**:
   - Authenticates users; navigates to `HomeScreen` on success.

7. **Home Screen (`home_screen.dart`)**:
   - Main screen with swipe cards for opportunities. Uses `CustomBottomNav` to navigate to:
     - **Favorites Screen (`favorites_screen.dart`)**: Lists saved opportunities.
     - **Profile Screen (`profile_screen.dart`)**: Displays and edits user profile (assumed based on context).

8. **Opportunity Details Screen (`opportunity_details_screen.dart`)**:
   - Shows detailed opportunity info (e.g., date, location, map), accessible by tapping a card on `HomeScreen`.

Navigation is managed via Flutter's `Navigator` with `push`, `pushReplacement`, and bottom navigation tab switches.

## Technologies Used
- **Flutter**: Version 3.22.0 (or latest stable release as of May 2025).
- **Dart**: Version 3.4.0 (compatible with Flutter 3.22.0).
- **Supabase**: For authentication and database management.
- **Android Studio**: IDE for development and debugging.
- **Dependencies**: `swipe_cards`, `shimmer`, `supabase_flutter`, `intl`, and others (see `pubspec.yaml`).

## Setup Instructions

### Prerequisites
- A computer with at least 8GB RAM (recommended).
- Operating System: Windows, macOS, or Linux.
- Internet connection for downloading tools and dependencies.

### Installing Flutter
1. **Download Flutter SDK**:
   - Visit the official Flutter website: [flutter.dev](https://flutter.dev).
   - Download the latest stable version (e.g., Flutter 3.22.0) for your OS.
   - Extract the zip file to a desired location (e.g., `C:\src\flutter` on Windows or `~/flutter` on macOS/Linux).

2. **Set Up Path**:
   - Add Flutter to your system PATH:
     - **Windows**: Add `C:\src\flutter\bin` to your environment variables.
     - **macOS/Linux**: Add `export PATH="$PATH:[PATH_TO_FLUTTER]/bin"` to your `~/.bashrc` or `~/.zshrc` and run `source ~/.bashrc` or `source ~/.zshrc`.
   - Verify installation by running `flutter doctor` in the terminal. Fix any issues (e.g., install Android SDK, Xcode, etc.).

3. **Install Dart**:
   - Dart is included with Flutter. Verify with `dart --version`.

### Installing Android Studio
1. **Download Android Studio**:
   - Visit [developer.android.com/studio](https://developer.android.com/studio).
   - Download the latest version (e.g., Android Studio Hedgehog or Iguana as of May 2025) for your OS.

2. **Install Android Studio**:
   - Run the installer and follow the setup wizard.
   - During installation, check the box to install the Android SDK, Android Virtual Device (AVD), and Android Emulator.

3. **Configure Android SDK**:
   - Open Android Studio > Configure > SDK Manager.
   - Install the latest Android SDK (e.g., API 34) and necessary tools (e.g., Android Emulator).

4. **Set Up Emulator**:
   - Create a virtual device via AVD Manager (e.g., Pixel 6 with API 34).
   - Start the emulator for testing.

### Setting Up the Project
1. **Clone the Repository**:
   - If the project is hosted on GitHub or another VCS, clone it:
     ```
     git clone <repository-url>
     ```
   - Otherwise, download the project ZIP and extract it.

2. **Open in Android Studio**:
   - Launch Android Studio.
   - Select "Open an existing Android Studio project" and navigate to the project folder.

3. **Install Dependencies**:
   - Run `flutter pub get` in the terminal or via Android Studio to install dependencies listed in `pubspec.yaml`.

4. **Configure Supabase**:
   - Update `supabase_config.dart` with your Supabase URL and anon key:
     ```dart
     import 'package:supabase_flutter/supabase_flutter.dart';

     class SupabaseConfig {
       static const String supabaseUrl = 'YOUR_SUPABASE_URL';
       static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
       static final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseAnonKey);
     }
     ```

5. **Run the App**:
   - Connect a physical device or start an emulator.
   - Click "Run" in Android Studio or use `flutter run` in the terminal.

## Dependencies
The `pubspec.yaml` file includes the following dependencies:
```yaml
name: voluncheers
description: A volunteer management app
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  swipe_cards: ^2.0.0
  shimmer: ^3.0.0
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```

- Update versions as needed based on the latest releases.
- The `assets/` folder includes animations like `confetti.json` (used in `signup_success_screen.dart`).

## Running the App
1. Ensure all dependencies are installed (`flutter pub get`).
2. Connect a device or start an emulator.
3. Run the app:
   - In Android Studio: Click the green "Run" button.
   - In terminal: Navigate to the project folder and run `flutter run`.

## Testing
VolunCheers includes unit and widget tests under the `test/` directory (though not provided in the current structure). To run tests:

1. Ensure `flutter_test` is listed in `dev_dependencies` in `pubspec.yaml`.
2. Create test files in the `test/` directory (e.g., `auth_service_test.dart` for testing `AuthService`).
3. Run tests using:
   ```
   flutter test
   ```
4. To run a specific test file:
   ```
   flutter test test/auth_service_test.dart
   ```
5. Use Android Studio's built-in test runner for a GUI experience.

### Example Test Setup
- Add a test for `AuthService` to verify signup functionality.
- Use `flutter_test` to mock Supabase responses and test edge cases.

## Troubleshooting
Here are common issues and solutions:

- **Flutter Doctor Issues**:
  - If `flutter doctor` reports missing Android SDK, install it via Android Studio's SDK Manager.
  - If no devices are detected, ensure an emulator is running or a physical device is connected with USB debugging enabled.

- **Supabase Connection Failed**:
  - Double-check `supabaseUrl` and `supabaseAnonKey` in `supabase_config.dart`.
  - Ensure your Supabase project is active and the anon key has appropriate permissions.

- **Emulator Not Starting**:
  - Verify that your system supports virtualization (e.g., enable Intel VT-x or AMD-V in BIOS).
  - Update the emulator in Android Studio’s AVD Manager.

- **Dependencies Not Found**:
  - Run `flutter pub get` to fetch dependencies.
  - If a package fails to install, check for version conflicts in `pubspec.yaml` and update to compatible versions.

- **App Crashes on Launch**:
  - Check the logs in Android Studio’s Run tab for errors.
  - Ensure all assets (e.g., `confetti.json`) are correctly placed in `assets/` and declared in `pubspec.yaml`.

## Future Enhancements
- **Real-Time Chat**: Implement the "Chat" tab in `CustomBottomNav` for user communication.
- **Push Notifications**: Add notifications for upcoming volunteering events.
- **Advanced Filtering**: Allow filtering opportunities by category, location, or date on `HomeScreen`.
- **Profile Picture Upload**: Enable users to upload a profile picture in the profile screen.
- **Analytics Dashboard**: Add a dashboard to visualize volunteering stats (e.g., hours per month).

## Contributing
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make changes and commit (`git commit -m "Add feature"`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

Please ensure your code follows the Flutter style guide and includes appropriate tests.

## Authors and Acknowledgments
- **Authors**:
  - [Your Name] - Lead Developer
- **Acknowledgments**:
  - The Flutter community for excellent documentation and packages.
  - Supabase team for providing a seamless backend solution.
  - Contributors to `swipe_cards` and `shimmer` packages for enhancing the app’s UX.

## Contact Information
For support or inquiries:
- **Email**: [your-email@example.com](mailto:your-email@example.com)
- **GitHub Issues**: Open an issue on the repository for bugs or feature requests.
- **Community**: Join our Discord server (link to be added) for discussions.

## Changelog
### May 26, 2025
- **Added**: Initial project setup with signup, login, and swipe functionality (06:45 AM +06).
- **Updated**: Navigation flow to include profile screen integration.
- **Fixed**: Minor UI bugs in `signup_success_screen.dart`.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.