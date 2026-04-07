# Onboarding Images

## 📁 Folder Location
`assets/images/onboarding/`

## 📝 File Naming Convention

Simpan gambar onboarding slide dengan nama berikut:

1. **Slide 1** (Welcome to HRIS):
   - `onboarding_slide_1.png` (atau `.jpg`)
   - Alternative: `onboarding_welcome.png`

2. **Slide 2** (Track Attendance):
   - `onboarding_slide_2.png` (atau `.jpg`)
   - Alternative: `onboarding_attendance.png`

3. **Slide 3** (Manage Leaves):
   - `onboarding_slide_3.png` (atau `.jpg`)
   - Alternative: `onboarding_leaves.png`

## 🎨 Recommended Specifications

- **Format**: PNG (with transparency) atau JPG
- **Size**: 800x800px atau lebih besar (akan di-scale otomatis)
- **Aspect Ratio**: Square (1:1) atau Portrait (3:4)
- **Quality**: High quality untuk tampilan yang baik di berbagai device

## 📦 Usage in Code

Setelah menyimpan gambar, gunakan di `onboarding_screen.dart`:

```dart
Image.asset(
  'assets/images/onboarding/onboarding_slide_1.png',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
)
```

## ✅ Checklist

- [ ] Simpan `onboarding_slide_1.png` (Welcome screen)
- [ ] Simpan `onboarding_slide_2.png` (Attendance screen)
- [ ] Simpan `onboarding_slide_3.png` (Leaves screen)
- [ ] Pastikan file sudah ada di folder ini
- [ ] Run `flutter pub get` untuk refresh assets
- [ ] Test di emulator/device

---

**Note**: Folder sudah di-configure di `pubspec.yaml` melalui `assets/images/` yang akan include semua subfolder termasuk `onboarding/`.
