# Cara Cek iOS Simulator

## ✅ Status Simulator Anda

Berdasarkan pengecekan:
- **iOS Simulator Tersedia**: ✅ Ya (Ada banyak device)
- **Simulator Running**: ❌ Tidak (Semua dalam status "Shutdown")

## 🔍 Cara Cek Simulator

### **Method 1: Via Flutter CLI** (Recommended)

```bash
# 1. Cek emulator yang tersedia
flutter emulators

# Output:
# apple_ios_simulator • iOS Simulator • Apple • ios
# 
# Jika ada, berarti simulator sudah terinstall

# 2. Cek device yang sedang running
flutter devices

# Output:
# - Jika simulator running, akan muncul:
#   iPhone XX (simulator) • ios • com.apple.CoreSimulator.SimDeviceType.xxx
# 
# - Jika tidak running, hanya muncul:
#   macOS (desktop) • macos • darwin-x64
#   Chrome (web) • chrome • web-javascript
```

### **Method 2: Via Xcode Simulator**

1. **Buka Xcode**
   ```bash
   open -a Simulator
   ```

2. **Atau via Xcode Menu**:
   - Xcode → Open Developer Tool → Simulator

3. **Atau langsung check di Xcode**:
   - Device selector di toolbar Xcode (atas)
   - Jika simulator tersedia, akan muncul di dropdown

### **Method 3: Via Command Line (xcrun simctl)**

```bash
# Cek semua simulator yang tersedia
xcrun simctl list devices available

# Output akan menampilkan:
# iPhone 15 Pro (UUID) (Shutdown)
# iPhone 16 Pro (UUID) (Shutdown)
# ... dan seterusnya

# Cek simulator yang sedang running
xcrun simctl list devices | grep Booted

# Output:
# - Jika ada yang running: akan muncul device dengan status "Booted"
# - Jika tidak ada yang running: tidak ada output
```

### **Method 4: Via Xcode Simulator Menu**

1. **Buka Simulator**
   ```bash
   open -a Simulator
   ```

2. **Menu**: File → Open Simulator
3. **Akan muncul list semua simulator yang tersedia**

## 🚀 Cara Launch Simulator

### **Method 1: Via Flutter CLI** (Paling Mudah)

```bash
# Launch iOS Simulator
flutter emulators --launch apple_ios_simulator

# Atau langsung run app (akan auto-launch simulator jika belum running)
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
flutter run -d ios
```

### **Method 2: Via Xcode Simulator App**

```bash
# Buka Simulator
open -a Simulator

# Pilih device di menu: File → Open Simulator → Pilih iPhone yang diinginkan
```

### **Method 3: Via Command Line (xcrun simctl)**

```bash
# List semua device
xcrun simctl list devices available | grep iPhone

# Launch specific device (contoh: iPhone 16 Pro)
xcrun simctl boot "iPhone 16 Pro"

# Atau dengan UUID
xcrun simctl boot CB6E89EA-F8B9-46CF-9482-5BB41A5DB57B

# Buka Simulator app
open -a Simulator
```

### **Method 4: Via Xcode**

1. **Buka Xcode**
   ```bash
   open /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app/ios/Runner.xcworkspace
   ```

2. **Pilih simulator di device selector** (toolbar atas)
3. **Klik Run** (▶️) atau press `⌘ + R`

## 📋 Checklist: Simulator Tersedia?

Gunakan checklist ini untuk verifikasi:

```bash
# 1. Cek emulator tersedia
flutter emulators | grep -i ios
# ✅ Jika muncul: "apple_ios_simulator • iOS Simulator"

# 2. Cek device list
xcrun simctl list devices available | grep -i iphone | wc -l
# ✅ Jika output > 0: Simulator tersedia

# 3. Cek simulator running
flutter devices | grep -i ios
# ✅ Jika muncul device iOS: Simulator sedang running
# ❌ Jika tidak muncul: Simulator belum running (tapi tersedia)
```

## 🎯 Quick Commands

```bash
# Cek simulator tersedia
flutter emulators

# Launch simulator
flutter emulators --launch apple_ios_simulator

# Cek device running
flutter devices

# List semua iPhone simulator
xcrun simctl list devices available | grep iPhone

# Launch simulator dan run app
cd hris_mobile_app
flutter run -d ios
```

## 🔍 Troubleshooting

### Jika `flutter emulators` tidak muncul iOS Simulator:

1. **Pastikan Xcode terinstall**:
   ```bash
   xcode-select --print-path
   ```

2. **Install Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

3. **Accept Xcode license**:
   ```bash
   sudo xcodebuild -license accept
   ```

### Jika simulator tidak bisa di-launch:

1. **Cek Xcode version**:
   ```bash
   xcodebuild -version
   ```

2. **Restart Xcode**:
   ```bash
   killall Xcode Simulator
   open -a Simulator
   ```

3. **Reset simulator** (last resort):
   ```bash
   xcrun simctl erase all
   ```

## 📝 Summary

✅ **Simulator Anda**: Sudah terinstall, ada banyak iPhone simulator  
❌ **Status**: Belum running (semua dalam status "Shutdown")  
🚀 **Langkah Selanjutnya**: Launch simulator dengan:
   ```bash
   flutter emulators --launch apple_ios_simulator
   ```
   atau
   ```bash
   cd hris_mobile_app && flutter run -d ios
   ```

---

**Tips**: Paling mudah adalah langsung run app dengan `flutter run -d ios`, Flutter akan otomatis launch simulator jika belum running!
