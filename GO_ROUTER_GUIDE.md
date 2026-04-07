# Go Router Guide

## 📋 Overview

Aplikasi menggunakan `go_router` untuk navigasi yang lebih clean dan maintainable. Semua routing configuration terpusat di satu file. Setiap route memiliki page transitions yang smooth dan menarik.

## 🗂️ File Structure

### **AppRouter** (`lib/core/routes/app_router.dart`)
File ini berisi semua konfigurasi routing aplikasi.

### **PageTransitions** (`lib/core/routes/page_transitions.dart`)
File ini berisi helper untuk berbagai jenis page transitions yang dapat digunakan di routes.

## 📝 Routes

### Available Routes

| Route | Path | Name | Description |
|-------|------|------|-------------|
| Splash | `/` | `splash` | Splash screen (initial screen) |
| Onboarding | `/onboarding` | `onboarding` | Onboarding screens |
| Login | `/login` | `login` | Login screen |
| Dashboard | `/dashboard` | `dashboard` | Main dashboard |

## 🚀 Penggunaan

### Import

```dart
import 'package:go_router/go_router.dart';
import 'package:hris_mobile_app/core/routes/app_router.dart';
```

### 1. Navigate (Replace current route)

```dart
// Navigate to login screen
context.go(AppRoutes.login);

// Navigate to dashboard
context.go(AppRoutes.dashboard);
```

### 2. Push (Add to navigation stack)

```dart
// Push new route on top of current route
context.push(AppRoutes.dashboard);
```

### 3. Pop (Go back)

```dart
// Go back to previous route
context.pop();
```

### 4. Named Navigation

```dart
// Using route name
context.goNamed(AppRoutes.loginName);
context.pushNamed(AppRoutes.dashboardName);
```

## 💻 Contoh Lengkap

### Di Login Screen

```dart
import 'package:go_router/go_router.dart';
import 'package:hris_mobile_app/core/routes/app_router.dart';

// After successful login
if (loginState.token != null) {
  context.go(AppRoutes.dashboard);
}
```

### Di Onboarding Screen

```dart
import 'package:go_router/go_router.dart';
import 'package:hris_mobile_app/core/routes/app_router.dart';

// After completing onboarding
void _navigateToLogin() async {
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.setBool('has_seen_onboarding', true);
  
  if (mounted) {
    context.go(AppRoutes.login);
  }
}
```

### Di Profile Screen

```dart
import 'package:go_router/go_router.dart';
import 'package:hris_mobile_app/core/routes/app_router.dart';

// Logout
void _handleLogout() {
  context.pop(); // Close dialog
  context.go(AppRoutes.login);
}

// View onboarding again
void _viewOnboarding() {
  context.go(AppRoutes.onboarding);
}
```

## 🔧 Menambahkan Route Baru

### 1. Tambahkan Route Path & Name

Edit `app_router.dart`:

```dart
class AppRoutes {
  // ... existing routes
  
  // Add new route
  static const String profile = '/profile';
  static const String profileName = 'profile';
}
```

### 2. Tambahkan GoRoute dengan Transition

```dart
GoRoute(
  path: AppRoutes.profile,
  name: AppRoutes.profileName,
  pageBuilder: (context, state) => PageTransitions.slide(
    context: context,
    state: state,
    child: const ProfileScreen(),
    duration: const Duration(milliseconds: 400),
  ),
),
```

### 3. Gunakan Route

```dart
// Navigate to profile
context.go(AppRoutes.profile);
```

## 🎯 Best Practices

### 1. **Selalu Gunakan AppRoutes Constants**
✅ **Benar:**
```dart
context.go(AppRoutes.login);
```

❌ **Salah:**
```dart
context.go('/login');
```

### 2. **Gunakan `go` untuk Replace, `push` untuk Stack**
- `context.go()` - Replace current route (untuk navigation utama)
- `context.push()` - Add to stack (untuk detail screens, dialogs, dll)

### 3. **Check `mounted` Before Navigation**
```dart
if (mounted) {
  context.go(AppRoutes.dashboard);
}
```

### 4. **Use `pop` untuk Dialog/Modal**
```dart
// Close dialog
context.pop();

// Close and navigate
context.pop();
context.go(AppRoutes.dashboard);
```

## 🔄 Redirect Logic

Router memiliki redirect logic untuk:
- Redirect ke onboarding jika user belum melihat onboarding
- Redirect ke login jika user sudah melihat onboarding tapi masih di onboarding screen

## 🎨 Page Transitions

Aplikasi menggunakan package `page_transition` untuk transisi yang lebih hidup dan menarik. Helper `PageTransitions` menyediakan berbagai jenis transitions yang dapat digunakan di routes.

### Available Transitions

1. **Fade** - Fade in/out transition
   ```dart
   PageTransitions.fade(
     context: context,
     state: state,
     child: const MyScreen(),
     duration: const Duration(milliseconds: 300),
   )
   ```

2. **Slide** - Slide from right
   ```dart
   PageTransitions.slide(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

3. **Slide Left** - Slide from left
   ```dart
   PageTransitions.slideLeft(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

4. **Scale** - Scale in/out transition
   ```dart
   PageTransitions.scale(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

5. **Rotate** - Rotate transition
   ```dart
   PageTransitions.rotate(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

6. **Fade Slide** - Top to bottom slide
   ```dart
   PageTransitions.fadeSlide(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

7. **Fade Scale** - Combined fade and scale
   ```dart
   PageTransitions.fadeScale(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

8. **Top to Bottom** - Slide from top
   ```dart
   PageTransitions.topToBottom(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

9. **Bottom to Top** - Slide from bottom
   ```dart
   PageTransitions.bottomToTop(
     context: context,
     state: state,
     child: const MyScreen(),
   )
   ```

10. **Left to Right with Fade** - Slide with fade effect
    ```dart
    PageTransitions.leftToRightWithFade(
      context: context,
      state: state,
      child: const MyScreen(),
    )
    ```

11. **Right to Left with Fade** - Slide with fade effect
    ```dart
    PageTransitions.rightToLeftWithFade(
      context: context,
      state: state,
      child: const MyScreen(),
    )
    ```

12. **None** - No transition (instant)
    ```dart
    PageTransitions.none(
      context: context,
      state: state,
      child: const MyScreen(),
    )
    ```

### Current Route Transitions

- **Splash** → Fade (500ms)
- **Onboarding** → Fade + Slide (500ms)
- **Login** → Slide from right (400ms)
- **Dashboard** → Fade + Scale (400ms)

## 📚 Advanced Features

### Route Parameters

```dart
// Define route with parameter
GoRoute(
  path: '/employee/:id',
  name: 'employee',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return EmployeeDetailScreen(employeeId: id);
  },
);

// Navigate with parameter
context.go('/employee/123');
```

### Query Parameters

```dart
// Navigate with query parameters
context.go('${AppRoutes.dashboard}?tab=profile');

// Read query parameters
final tab = state.uri.queryParameters['tab'];
```

### Nested Routes

```dart
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
```

## ✅ Checklist

Saat menggunakan go_router:

- [ ] Import `go_router` dan `app_router.dart`
- [ ] Gunakan `AppRoutes` constants untuk paths
- [ ] Check `mounted` sebelum navigation
- [ ] Gunakan `go` untuk replace, `push` untuk stack
- [ ] Test navigation flow

## 🎉 Benefits

1. **Centralized Routing** - Semua routes di satu tempat
2. **Type Safety** - Menggunakan constants, mengurangi typo
3. **Clean Navigation** - Syntax yang lebih clean dan readable
4. **Better Performance** - go_router lebih efficient
5. **Deep Linking** - Support untuk deep linking
6. **URL-based** - Routes berbasis URL, mudah untuk web

## 📦 Package Used

- **page_transition**: ^2.1.0
  - Package untuk berbagai jenis page transitions
  - Support banyak transition types (fade, slide, scale, rotate, dll)
  - Easy to use dan well maintained

## 📖 Resources

- [go_router Documentation](https://pub.dev/packages/go_router)
- [page_transition Documentation](https://pub.dev/packages/page_transition)
- [go_router Examples](https://github.com/flutter/packages/tree/main/packages/go_router/example)
