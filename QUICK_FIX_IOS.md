# Quick Fix iOS Build Error

## 🔴 Masalah Utama
```
Module 'image_picker_ios' not found
cannot load such file -- podhelper
```

**Root Cause**: Flutter installation tidak lengkap atau permission issue yang menyebabkan `podhelper` tidak bisa diakses.

## ✅ Solusi Lengkap (Step by Step)

### **STEP 1: Fix Flutter Permission** (WAJIB!)

**Ini harus dilakukan DULU sebelum lanjut ke step lain!**

1. **Buka System Settings**
   - Press `⌘ + Space` → ketik "System Settings"
   
2. **Privacy & Security → Full Disk Access**
   - Scroll ke bawah, cari "Full Disk Access"
   - Klik "+" → pilih **Terminal** (atau Cursor/VS Code)
   - Toggle **ON** (hijau)
   
3. **Restart Terminal/IDE** (tutup semua, buka lagi)

4. **Test Flutter**:
   ```bash
   flutter --version
   ```
   Jika masih error "Operation not permitted", ulangi step 1-3 atau lihat `FIX_PERMISSION_MACOS.md`

### **STEP 2: Regenerate Flutter Files**

Setelah Flutter permission fix:

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app

# Clean everything
flutter clean

# Regenerate files (ini akan generate podhelper yang dibutuhkan)
flutter pub get

# Verify Generated.xcconfig exists
ls -la ios/Flutter/Generated.xcconfig
```

### **STEP 3: Install CocoaPods**

```bash
cd ios

# Remove old pods
rm -rf Pods Podfile.lock .symlinks

# Install pods (sekarang podhelper sudah ada)
pod install --repo-update

cd ..
```

### **STEP 4: Build di Xcode**

```bash
# Open Xcode workspace (BUKAN .xcodeproj!)
open ios/Runner.xcworkspace
```

Di Xcode:
1. **Clean Build Folder**: `Product` → `Clean Build Folder` (⌘ + Shift + K)
2. **Pilih iOS Simulator** (device selector di atas)
3. **Build**: Klik Run (▶️) atau press `⌘ + R`

## 🔄 Alternative: Jika Flutter Permission Masih Bermasalah

Jika setelah Full Disk Access Flutter masih tidak bisa diakses, coba:

### Option A: Reinstall Flutter di Home Directory

```bash
# Install Flutter di home (biasanya tidak terbatasi)
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# Update PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
flutter --version
flutter doctor

# Update project
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### Option B: Build via Xcode (Tanpa Flutter CLI)

Jika Flutter CLI tidak bisa digunakan sama sekali:

1. **Pastikan CocoaPods terinstall**:
   ```bash
   sudo gem install cocoapods
   ```

2. **Generate files manual** (jika ada Flutter di path lain):
   - Cari Flutter di sistem yang bekerja
   - Atau install Flutter baru di home directory

3. **Atau gunakan pre-generated files**:
   - Jika ada backup, gunakan Generated.xcconfig yang lama
   - Atau minta developer lain untuk generate file

## ⚠️ Important Notes

1. **Selalu gunakan `Runner.xcworkspace`**, BUKAN `Runner.xcodeproj`
2. **Full Disk Access WAJIB** diberikan ke Terminal/IDE
3. **podhelper file harus ada** di Flutter installation
4. **CocoaPods harus terinstall**: `sudo gem install cocoapods`

## 🎯 Checklist

- [ ] ✅ Full Disk Access diberikan ke Terminal
- [ ] ✅ Flutter CLI bisa diakses (`flutter --version` works)
- [ ] ✅ `flutter pub get` berhasil
- [ ] ✅ `pod install` berhasil
- [ ] ✅ Build di Xcode berhasil

---

## 📞 Jika Masih Error

Jika setelah semua step masih error, kemungkinan:
1. Flutter installation corrupt - perlu reinstall
2. macOS version tidak compatible
3. Xcode version tidak compatible

**Recommended**: Fix Flutter permission dulu (STEP 1), itu adalah root cause dari semua masalah ini.
