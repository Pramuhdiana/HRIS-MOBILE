# Troubleshooting: Gambar Onboarding Tidak Muncul

## ✅ Checklist yang Sudah Dilakukan

1. ✅ File gambar sudah ada di `assets/images/onboarding/`
   - slide1.png (1.7 MB)
   - slide2.png (633 KB)
   - slide3.png (2.1 MB)

2. ✅ Path di code sudah benar:
   - `assets/images/onboarding/slide1.png`
   - `assets/images/onboarding/slide2.png`
   - `assets/images/onboarding/slide3.png`

3. ✅ `pubspec.yaml` sudah include `assets/images/`

4. ✅ Code sudah update untuk menggunakan `Image.asset`

5. ✅ Sudah `flutter clean` dan `flutter pub get`

## 🔧 Langkah-langkah Troubleshooting

### Step 1: Verifikasi File Assets

```bash
# Cek apakah file benar-benar ada
ls -la assets/images/onboarding/

# Harus muncul:
# - slide1.png
# - slide2.png
# - slide3.png
```

### Step 2: Verifikasi pubspec.yaml

Pastikan `pubspec.yaml` memiliki:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/logos/
```

### Step 3: Full Rebuild

```bash
cd hris_mobile_app

# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Full rebuild (bukan hot restart)
flutter run -d ios
# atau
flutter run -d android
```

### Step 4: Cek Console Logs

Saat aplikasi running, cek console untuk error messages. Code sudah ditambahkan `debugPrint` untuk menampilkan error jika gambar tidak ditemukan:

```
Error loading image: assets/images/onboarding/slide1.png
Error: [error details]
```

### Step 5: Cek Case Sensitivity

Pastikan nama file sama persis dengan yang di code:
- ✅ `slide1.png` (lowercase)
- ❌ `Slide1.png` (uppercase)
- ❌ `slide1.PNG` (uppercase extension)

### Step 6: Cek File Size

File gambar mungkin terlalu besar:
- slide1.png: 1.7 MB ✅ OK
- slide2.png: 633 KB ✅ OK
- slide3.png: 2.1 MB ✅ OK (agak besar tapi masih OK)

Jika masih tidak muncul, coba compress gambar.

### Step 7: Test dengan Path Absolute

Untuk testing, coba hardcode path langsung:

```dart
Image.asset(
  'assets/images/onboarding/slide1.png',
  width: 250,
  height: 250,
  fit: BoxFit.contain,
)
```

## 🐛 Common Issues

### Issue 1: File tidak terdeteksi oleh Flutter

**Solution**: 
- Pastikan file benar-benar di folder `assets/images/onboarding/`
- Run `flutter clean` dan `flutter pub get`
- Full rebuild (bukan hot restart)

### Issue 2: Path salah

**Solution**: 
- Path harus mulai dari `assets/` (tanpa `/` di awal)
- Tidak boleh: `/assets/images/onboarding/slide1.png`
- Harus: `assets/images/onboarding/slide1.png`

### Issue 3: Cache issue

**Solution**: 
```bash
flutter clean
flutter pub get
flutter run -d ios --release
```

### Issue 4: File corrupt

**Solution**: 
- Cek apakah file bisa dibuka di image viewer
- Coba compress ulang gambar
- Coba dengan gambar PNG/JPG yang berbeda untuk testing

## 📝 Debugging Code

Code sudah ditambahkan error handling dan debug print. Jika gambar tidak muncul, akan muncul error di console:

```dart
errorBuilder: (context, error, stackTrace) {
  debugPrint('Error loading image: ${data.imagePath}');
  debugPrint('Error: $error');
  // Fallback ke icon
}
```

Cek console untuk melihat error message.

## ✅ Final Check

Setelah semua langkah di atas:

1. **Stop aplikasi** (jika masih running)
2. **Full rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d ios
   ```
3. **Cek console** untuk error messages
4. **Cek apakah fallback icon muncul** (artinya path salah atau file tidak ditemukan)

## 🎯 Jika Masih Tidak Muncul

Jika setelah semua langkah gambar masih tidak muncul:

1. **Cek console logs** - Error message akan muncul
2. **Test dengan gambar kecil baru** - Untuk memastikan path benar
3. **Cek di device/emulator** - Bukan hanya di preview
4. **Cek file permission** - Pastikan file readable

---

**Note**: Setelah `flutter clean`, **wajib** rebuild penuh, bukan hanya hot restart!
