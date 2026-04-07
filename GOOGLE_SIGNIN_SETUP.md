# Google Sign-In Setup Guide

## 📋 Overview

Aplikasi sudah terintegrasi dengan Google Sign-In. Untuk menggunakan fitur ini, Anda perlu melakukan konfigurasi di Google Cloud Console dan project Flutter.

## 🔧 Setup Steps

### 1. Google Cloud Console Setup

1. **Buka [Google Cloud Console](https://console.cloud.google.com/)**
2. **Buat atau pilih project**
3. **Enable Google Sign-In API:**
   - Navigate ke "APIs & Services" > "Library"
   - Search "Google Sign-In API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials:**
   - Navigate ke "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Application type: **Android** atau **iOS**
   - Masukkan informasi yang diperlukan

### 2. Android Setup

#### 2.1. Get SHA-1 Certificate Fingerprint

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (jika sudah ada)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

#### 2.2. Add SHA-1 to Google Cloud Console

1. Copy SHA-1 fingerprint dari command di atas
2. Di Google Cloud Console, saat membuat OAuth client ID untuk Android:
   - Masukkan **Package name**: `com.example.hris_mobile_app` (sesuaikan dengan package name Anda)
   - Masukkan **SHA-1 certificate fingerprint**
   - Click "Create"

#### 2.3. Download google-services.json

1. Download file `google-services.json` dari Google Cloud Console
2. Place di: `android/app/google-services.json`

#### 2.4. Update android/app/build.gradle

```gradle
dependencies {
    // ... existing dependencies
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### 3. iOS Setup

#### 3.1. Get Bundle ID

1. Buka `ios/Runner.xcodeproj` di Xcode
2. Pilih target "Runner"
3. Di tab "General", copy **Bundle Identifier**

#### 3.2. Add Bundle ID to Google Cloud Console

1. Di Google Cloud Console, saat membuat OAuth client ID untuk iOS:
   - Masukkan **Bundle ID** (contoh: `com.example.hrisMobileApp`)
   - Masukkan **App Store ID** (opsional, untuk production)
   - Click "Create"

#### 3.3. Download GoogleService-Info.plist

1. Download file `GoogleService-Info.plist` dari Google Cloud Console
2. Place di: `ios/Runner/GoogleService-Info.plist`
3. Add ke Xcode project (drag & drop ke Runner folder)

#### 3.4. Update ios/Runner/Info.plist

Tambahkan URL scheme untuk Google Sign-In:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Note:** Ganti `YOUR-CLIENT-ID` dengan Client ID dari Google Cloud Console (format: `xxxxx-xxxxx.apps.googleusercontent.com`)

### 4. Update API Endpoint

Pastikan backend API endpoint untuk Google login sudah sesuai. Default endpoint:
- `/ms-auth/api/auth/login/google`

Jika endpoint berbeda, update di:
- `lib/data/datasources/remote/auth_datasource.dart`
- Method `loginWithGoogle()`

## 🧪 Testing

### Test Google Sign-In

1. **Run aplikasi:**
   ```bash
   flutter run
   ```

2. **Test flow:**
   - Tap "Lanjutkan dengan Google"
   - Pilih akun Google
   - Verify token diterima dari backend
   - Verify navigation ke dashboard

### Debug Issues

Jika Google Sign-In tidak berfungsi:

1. **Check logs:**
   - Lihat console untuk error messages
   - Check API logger untuk request/response

2. **Verify configuration:**
   - Pastikan SHA-1 (Android) atau Bundle ID (iOS) sudah benar
   - Pastikan `google-services.json` / `GoogleService-Info.plist` sudah di tempat yang benar
   - Pastikan OAuth client ID sudah dibuat di Google Cloud Console

3. **Common issues:**
   - **"DEVELOPER_ERROR"**: SHA-1 atau Bundle ID tidak match
   - **"SIGN_IN_REQUIRED"**: User belum sign in ke Google
   - **Network error**: Check internet connection dan API endpoint

## 📝 Notes

- Google Sign-In memerlukan internet connection
- User harus memiliki akun Google
- Token dari Google akan dikirim ke backend untuk verifikasi
- Backend harus mengimplementasikan endpoint `/ms-auth/api/auth/login/google`

## 🔒 Security

- Jangan commit `google-services.json` atau `GoogleService-Info.plist` ke public repository
- Gunakan environment variables untuk sensitive data
- Pastikan OAuth client ID hanya digunakan untuk aplikasi yang sesuai

## 📚 Resources

- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Google Sign-In Documentation](https://developers.google.com/identity/sign-in/web/sign-in)
- [Flutter Google Sign-In Guide](https://docs.flutter.dev/cookbook/authentication/google)
