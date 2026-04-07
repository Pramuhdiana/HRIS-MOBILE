# Fix "Operation not permitted" pada macOS

## 🔴 Masalah
```
bash: /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/flutter: Operation not permitted
```

Ini adalah **macOS Security Protection** yang memblokir Flutter binary.

## ✅ Solusi (Urut sesuai prioritas)

### **Solusi 1: Full Disk Access untuk Terminal** ⭐ (Paling Mudah)

1. **Buka System Settings** (macOS Ventura+) atau **System Preferences** (macOS Monterey-)
   - Press `⌘ + Space` → ketik "System Settings"
   - Atau klik Apple Menu → System Settings

2. **Masuk ke Privacy & Security**
   - Scroll ke bawah, cari **Full Disk Access**

3. **Tambah Terminal/VS Code/Cursor**
   - Klik **+** atau **Add Application**
   - Pilih **Terminal** (atau VS Code / Cursor yang Anda pakai)
   - Pastikan toggle sudah **ON** (hijau)

4. **Restart Terminal/IDE**
   - Tutup semua terminal/IDE
   - Buka kembali terminal baru
   - Test: `flutter --version`

### **Solusi 2: Gunakan Xcode untuk Build iOS** ⭐ (Alternatif)

Jika Flutter CLI masih bermasalah, gunakan Xcode langsung:

```bash
# 1. Buka project di Xcode
open /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app/ios/Runner.xcworkspace

# 2. Di Xcode:
#    - Pilih iOS Simulator di device selector (atas)
#    - Klik Run (▶️) atau press ⌘ + R
```

### **Solusi 3: Reinstall Flutter di Home Directory** (Jika Solusi 1 Tidak Berhasil)

Pindahkan Flutter ke home directory (biasanya tidak terbatasi):

```bash
# 1. Download Flutter ke home directory
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 2. Update PATH di ~/.zshrc
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 3. Verify
flutter --version
flutter doctor

# 4. Update project PATH (jika perlu)
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
flutter clean
flutter pub get
```

### **Solusi 4: Disable SIP** ❌ (TIDAK DISARANKAN)

**JANGAN** disable System Integrity Protection kecuali benar-benar perlu. Ini membahayakan keamanan macOS.

## 🧪 Test Setelah Fix

```bash
# Test Flutter
flutter --version
flutter doctor

# Test di project
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
flutter clean
flutter pub get
flutter run -d ios
```

## 📝 Catatan

- **Solusi 1** (Full Disk Access) adalah yang paling aman dan disarankan
- Error ini umum terjadi setelah macOS update atau Flutter upgrade
- Biasanya hanya perlu sekali fix, setelah itu tidak akan muncul lagi
- Jika masih error setelah Solusi 1, gunakan Solusi 2 (Xcode) sebagai alternatif

## 🔍 Check Current Status

Untuk cek apakah permission sudah benar:

```bash
# Check file permission
ls -la /Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/flutter

# Check if accessible
/Users/developer/Documents/developer_sanivokasi/aplikasi/flutter/bin/flutter --version

# Check Full Disk Access status (macOS Ventura+)
tccutil reset All com.apple.Terminal  # Reset permission (optional)
```

---

**Recommended Action**: Lakukan **Solusi 1** (Full Disk Access) terlebih dahulu. Ini yang paling mudah dan aman.
