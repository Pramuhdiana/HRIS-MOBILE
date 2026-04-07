# Fix iOS Module 'image_picker_ios' Not Found Error

## 🔴 Error
```
Module 'image_picker_ios' not found
/Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app/ios/Runner/GeneratedPluginRegistrant.m:12:9
```

## ✅ Solusi

Ini adalah masalah **CocoaPods dependencies** yang belum terinstall dengan benar.

### **Method 1: Via Terminal (Jika Flutter CLI sudah fix permission)**

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app

# 1. Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/build ios/DerivedData

# 2. Regenerate Flutter files
flutter pub get

# 3. Install CocoaPods
cd ios
pod deintegrate  # Remove old pods if exists
pod install --repo-update
cd ..

# 4. Open Xcode and build
open ios/Runner.xcworkspace
```

### **Method 2: Manual Fix di Xcode** (Jika Flutter CLI masih bermasalah)

#### Step 1: Clean Xcode Project

1. **Buka Xcode**
   ```bash
   open /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app/ios/Runner.xcworkspace
   ```

2. **Clean Build Folder**
   - Menu: **Product** → **Clean Build Folder** (atau `⌘ + Shift + K`)

3. **Delete Derived Data**
   - Menu: **Xcode** → **Settings** (Preferences) → **Locations**
   - Klik arrow (→) di sebelah **Derived Data**
   - Delete folder `DerivedData`
   - Atau jalankan:
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData
     ```

#### Step 2: Install CocoaPods via Terminal

Buka Terminal baru (pastikan sudah di project directory):

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app/ios

# Remove old pods
rm -rf Pods Podfile.lock .symlinks

# Install pods
pod install --repo-update
```

**Note**: Jika `pod install` error karena Flutter permission, perlu fix Flutter permission dulu (lihat `FIX_PERMISSION_MACOS.md`).

#### Step 3: Rebuild di Xcode

1. **Close Xcode** (tutup semua window)
2. **Reopen Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```
3. **Pilih iOS Simulator** di device selector (atas)
4. **Build**: Klik **Run** (▶️) atau press `⌘ + R`

### **Method 3: Via Script Otomatis**

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
bash fix_ios_pods.sh
```

## 🔍 Verifikasi

Setelah fix, verifikasi:

```bash
# Check if Pods installed
ls -la ios/Pods | head -10

# Check if image_picker_ios exists
ls -la ios/Pods/Headers/Public/image_picker_ios 2>/dev/null && echo "✅ image_picker_ios found" || echo "❌ image_picker_ios not found"
```

## 📝 Troubleshooting

### Jika `pod install` masih error:

1. **Update CocoaPods**:
   ```bash
   sudo gem install cocoapods
   pod repo update
   ```

2. **Clear CocoaPods cache**:
   ```bash
   pod cache clean --all
   rm -rf ~/Library/Caches/CocoaPods
   ```

3. **Reinstall pods**:
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

### Jika masih "Module not found" setelah pod install:

1. **Close Xcode completely**
2. **Delete DerivedData**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Open Xcode again**:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. **Product → Clean Build Folder** (`⌘ + Shift + K`)
5. **Build again** (`⌘ + R`)

## ⚠️ Important Notes

- **Selalu gunakan `Runner.xcworkspace`**, bukan `Runner.xcodeproj`
- **Pastikan Flutter permission sudah fix** sebelum menjalankan `flutter pub get`
- **CocoaPods harus terinstall**: `gem install cocoapods`

## 🎯 Quick Fix Checklist

- [ ] Clean iOS build artifacts
- [ ] Run `flutter pub get` (butuh Flutter permission fix)
- [ ] Run `pod install` di folder `ios/`
- [ ] Clean Xcode build folder (`⌘ + Shift + K`)
- [ ] Close and reopen Xcode
- [ ] Build again (`⌘ + R`)

---

**Jika masih error setelah semua step, kemungkinan Flutter permission belum fix. Fix dulu permission (lihat `FIX_PERMISSION_MACOS.md`), lalu ulangi step di atas.**
