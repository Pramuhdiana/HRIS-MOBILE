# Fix Permission Issue Setelah Flutter Upgrade

## Problem
Setelah upgrade Flutter ke 3.38.6, terjadi error:
- `Operation not permitted` pada Flutter binary
- `Cannot open file Flutter.xcframework/.../module.modulemap: Operation not permitted`
- Podhelper tidak ditemukan

## Solusi (Pilih salah satu)

### Method 1: Fix Permission via Terminal (Recommended)

Buka Terminal dan jalankan:

```bash
# 1. Fix Flutter binary permission
chmod +x /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/flutter
chmod +x /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/dart

# 2. Remove quarantine attribute (macOS security)
xattr -d com.apple.quarantine /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/flutter 2>/dev/null
xattr -d com.apple.quarantine /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/dart 2>/dev/null

# 3. Fix permission pada Flutter directory
chmod -R 755 /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin
chmod -R 755 /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/packages/flutter_tools/bin

# 4. Jika masih error, mungkin perlu sudo (akan minta password)
sudo chmod -R 755 /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin
sudo chmod -R 755 /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/packages/flutter_tools/bin
```

### Method 2: Fix via System Preferences (macOS)

1. Buka **System Preferences** > **Security & Privacy**
2. Tab **Privacy**
3. Pilih **Full Disk Access**
4. Klik **+** dan tambahkan Terminal/VS Code/Cursor
5. Restart Terminal/IDE

### Method 3: Reinstall Flutter (Jika method lain tidak berhasil)

```bash
# Backup Flutter path
cd /Users/developer/Documents/developer_sanivokasi/aplikasi

# Download Flutter terbaru
git clone https://github.com/flutter/flutter.git -b stable flutter_new

# Atau jika sudah ada, pull latest
cd flutter_new
git pull origin stable

# Set path
export PATH="$PWD/bin:$PATH"

# Verify
flutter doctor
```

## Setelah Fix Permission, Rebuild Project

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app

# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Generate iOS files
cd ios
pod deintegrate
pod install
cd ..

# 4. Run di iOS simulator
flutter run -d ios
```

## Alternative: Build via Xcode

Jika Flutter CLI masih bermasalah:

1. Buka **Xcode**
2. File > Open > pilih `hris_mobile_app/ios/Runner.xcworkspace`
3. Pilih simulator di device selector
4. Klik **Run** (▶️)

## Notes

- Error ini umum terjadi setelah Flutter upgrade karena macOS security
- Method 1 biasanya paling efektif
- Pastikan Terminal/IDE punya Full Disk Access jika tetap error
