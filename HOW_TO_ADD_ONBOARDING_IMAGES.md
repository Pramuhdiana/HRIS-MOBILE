# Cara Menambahkan Gambar Onboarding Slide

## 📁 Lokasi Folder

Simpan gambar slide onboarding di folder berikut:

```
assets/images/onboarding/
```

## 📝 Nama File yang Disarankan

1. **Slide 1** (Welcome to HRIS):
   - `onboarding_slide_1.png` ✅ Recommended
   - atau `onboarding_welcome.png`

2. **Slide 2** (Track Attendance):
   - `onboarding_slide_2.png` ✅ Recommended
   - atau `onboarding_attendance.png`

3. **Slide 3** (Manage Leaves):
   - `onboarding_slide_3.png` ✅ Recommended
   - atau `onboarding_leaves.png`

## 🎨 Spesifikasi Gambar

### Format File
- **PNG** (disarankan jika ada transparansi)
- **JPG/JPEG** (disarankan jika tidak ada transparansi, file size lebih kecil)

### Ukuran
- **Minimal**: 800x800px
- **Recommended**: 1200x1200px atau lebih besar
- **Aspect Ratio**: Square (1:1) atau Portrait (3:4)

### Kualitas
- **High Quality**: Pastikan gambar tidak blur/pixelated
- **Optimized**: Jangan terlalu besar (max 1-2MB per file)

## 📦 Langkah-langkah

### Step 1: Simpan Gambar

Copy gambar Anda ke folder:
```
hris_mobile_app/assets/images/onboarding/
```

Struktur folder setelah menambahkan gambar:
```
assets/
  └── images/
      └── onboarding/
          ├── onboarding_slide_1.png  ← Slide 1
          ├── onboarding_slide_2.png  ← Slide 2
          └── onboarding_slide_3.png  ← Slide 3
```

### Step 2: Verifikasi pubspec.yaml

Pastikan folder `assets/images/` sudah ada di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/logos/
```

✅ **Sudah dikonfigurasi!** Folder `assets/images/` akan include semua subfolder termasuk `onboarding/`.

### Step 3: Refresh Assets

Setelah menyimpan gambar, jalankan:

```bash
cd hris_mobile_app
flutter pub get
```

### Step 4: Hot Restart

Untuk melihat perubahan gambar, lakukan **Hot Restart** (bukan Hot Reload):

- **VS Code/Cursor**: Press `Ctrl+Shift+F5` (Windows/Linux) atau `Cmd+Shift+F5` (Mac)
- **Terminal**: Press `R` (capital R) di Flutter run terminal
- **Android Studio**: Klik Hot Restart icon (↻)

## 💻 Cara Menggunakan di Code

Saat ini onboarding screen menggunakan **Icon** dan **Color**. Jika Anda ingin menggunakan **Gambar**, ada 2 opsi:

### Opsi 1: Tetap Pakai Icon (Current)

Onboarding screen saat ini sudah menggunakan icon dan color gradient. Ini bekerja dengan baik dan performanya lebih ringan.

### Opsi 2: Ganti ke Gambar

Jika ingin menggunakan gambar, bisa update `OnboardingPageData` untuk support image path:

```dart
// Di onboarding_screen.dart
OnboardingPageData(
  title: l10n.welcomeToHRIS,
  description: l10n.welcomeDescription,
  icon: Icons.business_center_rounded,
  color: AppColors.primary,
  imagePath: 'assets/images/onboarding/onboarding_slide_1.png', // Tambahkan ini
),
```

Dan update widget untuk menampilkan gambar:

```dart
// Ganti Icon dengan Image
Image.asset(
  data.imagePath ?? '', // atau langsung path
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    // Fallback ke icon jika gambar tidak ditemukan
    return Icon(data.icon, size: 80, color: data.color);
  },
)
```

## ✅ Checklist

- [ ] Folder `assets/images/onboarding/` sudah dibuat ✅
- [ ] Simpan `onboarding_slide_1.png` (Welcome screen)
- [ ] Simpan `onboarding_slide_2.png` (Attendance screen)
- [ ] Simpan `onboarding_slide_3.png` (Leaves screen)
- [ ] Verifikasi `pubspec.yaml` sudah include `assets/images/`
- [ ] Run `flutter pub get`
- [ ] Hot Restart aplikasi
- [ ] Test di emulator/device

## 🔍 Troubleshooting

### Gambar tidak muncul?

1. **Check path file**: Pastikan file ada di `assets/images/onboarding/`
2. **Check pubspec.yaml**: Pastikan `assets/images/` ada di assets list
3. **Run flutter pub get**: Setelah menambah gambar baru
4. **Hot Restart**: Jangan hanya Hot Reload, harus Hot Restart
5. **Check case sensitivity**: Path harus tepat (lowercase/uppercase)
6. **Check file extension**: Pastikan `.png` atau `.jpg` sesuai

### File size terlalu besar?

- Gunakan tool compress seperti [TinyPNG](https://tinypng.com/) atau [ImageOptim](https://imageoptim.com/)
- Convert ke JPG jika tidak perlu transparansi
- Resize gambar ke ukuran yang sesuai (1200x1200px cukup)

## 📚 Referensi

- Flutter Assets Documentation: https://flutter.dev/docs/development/ui/assets-and-images
- Image Optimization: https://flutter.dev/docs/perf/images

---

**Note**: Saat ini onboarding menggunakan icon yang sudah bagus dan performanya ringan. Gambar bisa ditambahkan jika memang diperlukan untuk branding atau design tertentu.
