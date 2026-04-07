# HRIS Mobile Application

Human Resource Information System (HRIS) mobile app built with Flutter. UI is inspired by modern HR dashboards; the **login** flow uses a **glassmorphism** (frosted glass) style with optional **Google Sign-In**.

## Features

### Dashboard
- Welcome / home with quick access to main areas
- Attendance snapshot and shortcuts (structure ready for backend wiring)
- Tab navigation (home, attendance, leave, profile)

### Attendance & leave
- Attendance and leave screens with cards, lists, and mock-oriented layouts
- Ready to connect to real APIs when endpoints are available

### Profile
- Employee-oriented profile UI; session-aware display when auth data is available
- Logout flow aligned with backend / local session rules

### Authentication & onboarding
- **Email + password** login with validation messages shown **below** each field (outside the glass inputs)
- **Google Sign-In** (configure OAuth per `GOOGLE_SIGNIN_SETUP.md` and platform files)
- **Onboarding** slides (Lottie + assets under `assets/images/onboarding/`)
- **Splash** with session restore when applicable

### UX / UI
- **Liquid Glass–style notifications**: success, error, warning, and info messages use a top overlay with blur and motion (see `lib/core/utils/liquid_glass_toast.dart` and `SnackBarHelper`)
- **Branding**: HRIS Portal logo on login (`assets/images/logo_login.png`)

## Design system

- **App theme**: primary blues and neutrals in `lib/core/themes/app_theme.dart` and `lib/core/constants/app_colors.dart`
- **Login screen**: separate glass treatment (background image, translucent pills, `_GlassInput` / `_GlassButton`)
- **Typography & spacing**: `app_typography.dart`, `app_dimensions.dart`

## Architecture (overview)

```
lib/
├── core/
│   ├── constants/       # API, colors, typography, Google Sign-In config, etc.
│   ├── network/         # Api client, helper, logging
│   ├── routes/          # go_router setup
│   ├── themes/
│   └── utils/           # SnackBarHelper, liquid_glass_toast, ...
├── data/
│   ├── datasources/     # Remote auth, local Google session storage, ...
│   └── models/
├── domain/              # Entities / use case stubs (expand as needed)
├── l10n/                # ARB + generated localizations (e.g. en, id)
└── presentation/
    ├── providers/       # Riverpod (auth, profile snapshot, app providers, …)
    ├── screens/
    │   ├── splash/
    │   ├── auth/        # login_screen.dart (glass UI)
    │   ├── onboarding/
    │   ├── dashboard/
    │   ├── attendance/
    │   ├── leave/
    │   └── profile/
    └── widgets/
```

- **State management**: **Riverpod** (`flutter_riverpod`), not the legacy `provider` package.
- **Navigation**: **go_router**
- **Layering**: data/domain/presentation separation; extend repositories and datasources when APIs are fixed.

## Getting started

### Prerequisites
- **Flutter** with **Dart SDK ^3.8.1** (see `pubspec.yaml`)
- **Xcode** (iOS), **Android Studio / SDK** (Android)

### Install

```bash
git clone <repository-url>
cd hris_mobile_app
flutter pub get
```

Example remotes (use the one your team uses):

- `https://github.com/yudiyusuf/sanivokasi-sani-mobile.git`
- `https://github.com/Pramuhdiana/HRIS-MOBILE.git`

### Run

```bash
flutter run -d chrome    # web
flutter run -d ios         # iOS simulator / device
flutter run -d android     # Android emulator / device
```

### Demo login (if your backend accepts them)
- **Email**: `demo@company.com`
- **Password**: `demo123`

Replace with credentials from your environment when integrating the real API.

## Main dependencies

| Area | Packages (selected) |
|------|---------------------|
| State | `flutter_riverpod`, `riverpod_annotation` |
| Routing | `go_router`, `go_router_builder` |
| HTTP | `dio`, `http` |
| Storage | `shared_preferences`, `path_provider` |
| Auth | `google_sign_in` |
| UI | `lottie`, `flutter_svg`, `cached_network_image`, `smooth_page_indicator`, `page_transition` |
| Feedback | `awesome_snackbar_content` (e.g. material banner paths); primary in-app messages use **Liquid Glass** overlay via `SnackBarHelper` |
| i18n | `flutter_localizations`, `intl`, generated code from `lib/l10n/*.arb` |

## API integration

- Endpoints and helpers live under `lib/core/constants/` and `lib/core/network/`.
- Auth flows: `lib/presentation/providers/auth_provider.dart`, remote datasources under `lib/data/datasources/remote/`.
- See `ARCHITECTURE.md` and `API_HELPER_GUIDE.md` for deeper detail.

## Deployment

- **iOS**: `flutter build ios --release` (signing via Xcode).
- **Android**: `flutter build apk` / `appbundle` as required by Play Console.
- **Web**: `flutter build web` — deploy the `build/web` output to your host.

## Security notes

- Do not commit production secrets. Keep OAuth client configs and keys out of public forks if they are sensitive.
- Adjust `google_sign_in_config.dart` and platform OAuth files per environment.

## Roadmap (examples)

- Deeper API integration for attendance, leave, and profile
- Push notifications
- Biometric unlock
- Offline cache + sync
- Expanded tests and CI/CD

## Contributing

1. Branch from `main` (or your team’s default branch).
2. Commit with clear messages.
3. Open a merge/pull request for review.

## Support

- Track issues in the GitHub repository you use for this project.
- Internal docs: `DEVELOPER_GUIDE.md`, `GOOGLE_SIGNIN_SETUP.md`, `SNACKBAR_HELPER_GUIDE.md`, etc.

---

**Status**: Active development — UI, auth plumbing, onboarding, and localization are in place; connect and harden APIs for production.

*Built with Flutter.*
