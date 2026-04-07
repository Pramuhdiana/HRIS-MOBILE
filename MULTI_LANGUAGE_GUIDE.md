# Multi-Language Support Guide

## Overview
HRIS Mobile Application supports **Indonesian (id)** and **English (en)** languages. The language preference is saved in SharedPreferences and persists across app restarts.

## Architecture

### 1. Localization Files
- **Location**: `lib/l10n/`
- **Files**:
  - `app_en.arb` - English translations (template)
  - `app_id.arb` - Indonesian translations
  - `app_localizations.dart` - Generated localization class (auto-generated)

### 2. Configuration
- **l10n.yaml**: Configuration file for localization generation
- **pubspec.yaml**: Includes `flutter_localizations` SDK

### 3. Language Provider
- **Location**: `lib/presentation/providers/app_providers.dart`
- **Provider**: `languageProvider` - Manages current app language
- **Storage**: Language preference saved in SharedPreferences with key `app_language`
- **Default**: Indonesian (`id`)

## Usage

### In Widgets

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.welcome); // Use localized string
  }
}
```

### Changing Language

```dart
// Get current language
final currentLocale = ref.watch(languageProvider);

// Set language
ref.read(languageProvider.notifier).setLanguage(const Locale('en'));

// Toggle between id and en
ref.read(languageProvider.notifier).toggleLanguage();
```

### Language Switcher Widget

A ready-to-use widget is available at:
- **Location**: `lib/presentation/widgets/language_switcher.dart`
- **Usage**: Add `<LanguageSwitcher />` to any screen (already added to Profile Tab)

## Adding New Translations

### Step 1: Add to English Template (`app_en.arb`)

```json
{
  "myNewKey": "My New Text",
  "@myNewKey": {
    "description": "Description of the text"
  }
}
```

### Step 2: Add to Indonesian (`app_id.arb`)

```json
{
  "myNewKey": "Teks Baru Saya"
}
```

### Step 3: Regenerate Localization Files

```bash
flutter gen-l10n
```

### Step 4: Use in Code

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewKey);
```

## Supported Locales

Currently supported:
- **Indonesian (id)** - Default
- **English (en)**

To add more languages:
1. Create new ARB file: `app_<locale>.arb` (e.g., `app_es.arb` for Spanish)
2. Add locale to `supportedLocales` in `main.dart`
3. Run `flutter gen-l10n`

## Best Practices

1. **Always use localization**: Never hardcode user-facing strings
2. **Use descriptive keys**: Use clear, descriptive keys for translations
3. **Add descriptions**: Always add `@key` with description in English template
4. **Test both languages**: Always test your UI in both languages
5. **Consider text length**: Indonesian text can be longer than English - design UI accordingly

## Current Translated Screens

✅ Onboarding Screen
✅ Login Screen
✅ Profile Tab (with Language Switcher)

## Future Work

- [ ] Translate all remaining screens
- [ ] Add language detection based on device locale
- [ ] Add more languages (if needed)
- [ ] Add date/time formatting based on locale
- [ ] Add number formatting based on locale

## Notes

- Language preference is saved in SharedPreferences
- App restarts when language changes (automatic via MaterialApp rebuild)
- All generated files are in `.gitignore` - they are auto-generated
- ARB files should be committed to version control