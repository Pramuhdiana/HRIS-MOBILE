# Fix Android SDK Installation Error

## 🔴 Error
```
An error occurred while preparing SDK package Android SDK Build-Tools 36.1: Not in GZIP format.
An error occurred while preparing SDK package Android SDK Command-line Tools (latest): Not in GZIP format.
```

## ✅ Solusi

### **Method 1: Clear Android SDK Cache & Retry** (Disarankan)

```bash
# 1. Stop semua Android processes
killall -9 adb java 2>/dev/null || true

# 2. Clear Android SDK cache
rm -rf ~/Library/Caches/Android
rm -rf ~/.android/cache

# 3. Clear temporary download files
rm -rf ~/.android/download-cache
rm -rf /tmp/android-*

# 4. Jika pakai Android Studio, clear cache juga
rm -rf ~/Library/Application\ Support/Google/AndroidStudio*/caches

# 5. Retry installation via Android Studio
# Tools → SDK Manager → SDK Tools → Install missing tools
```

### **Method 2: Manual Download & Install** (Jika Method 1 gagal)

#### Step 1: Download Manual

```bash
# Create temp directory
mkdir -p ~/Downloads/android_sdk_fix
cd ~/Downloads/android_sdk_fix

# Download Build-Tools manually
# Note: URL bisa berubah, check di Android Studio SDK Manager untuk URL terbaru
curl -L -o build-tools.zip "https://dl.google.com/android/repository/build-tools_r36.1_macosx.zip"

# Download Command-line Tools manually
curl -L -o cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-mac-13114758_latest.zip"
```

#### Step 2: Verify & Extract

```bash
# Check if files are valid ZIP (not corrupted)
unzip -t build-tools.zip
unzip -t cmdline-tools.zip

# If valid, extract to Android SDK location
ANDROID_SDK_PATH="$HOME/Library/Android/sdk"

# Extract Build-Tools
unzip -q build-tools.zip -d "$ANDROID_SDK_PATH/build-tools"
# Rename extracted folder to match version
mv "$ANDROID_SDK_PATH/build-tools/android-36.1.0" "$ANDROID_SDK_PATH/build-tools/36.1.0" 2>/dev/null || true

# Extract Command-line Tools
unzip -q cmdline-tools.zip -d "$ANDROID_SDK_PATH"
# Ensure proper structure: cmdline-tools/latest/
mkdir -p "$ANDROID_SDK_PATH/cmdline-tools/latest"
unzip -q cmdline-tools.zip -d "$ANDROID_SDK_PATH/cmdline-tools/latest"
mv "$ANDROID_SDK_PATH/cmdline-tools/latest/cmdline-tools/*" "$ANDROID_SDK_PATH/cmdline-tools/latest/" 2>/dev/null || true

# Cleanup
cd ~
rm -rf ~/Downloads/android_sdk_fix
```

#### Step 3: Verify Installation

```bash
# Check if installed correctly
ls -la ~/Library/Android/sdk/build-tools/
ls -la ~/Library/Android/sdk/cmdline-tools/

# Update PATH if needed
echo 'export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify with Flutter
flutter doctor -v
```

### **Method 3: Via Android Studio SDK Manager (Recommended)**

1. **Buka Android Studio**
2. **Tools** → **SDK Manager**
3. **SDK Tools tab**
4. **Uncheck** semua tools yang error
5. **Apply** (uninstall jika sudah terinstall)
6. **Check again** tools yang diperlukan
7. **Apply** (reinstall)

**Tips**: Coba install satu per satu, bukan sekaligus:
- Install **Command-line Tools** dulu
- Restart Android Studio
- Install **Build-Tools** setelahnya

### **Method 4: Update Android SDK Location via Flutter**

```bash
# Check Android SDK location
flutter doctor -v

# Jika path berbeda, set Android SDK location
# Di Android Studio: Tools → SDK Manager → Android SDK Location
# Atau set via environment variable:
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
```

### **Method 5: Reinstall Android SDK (Last Resort)**

Jika semua method gagal:

```bash
# Backup current SDK (optional)
mv ~/Library/Android/sdk ~/Library/Android/sdk.backup

# Remove old SDK
rm -rf ~/Library/Android/sdk

# Reinstall via Android Studio:
# 1. Android Studio → Welcome Screen
# 2. More Actions → SDK Manager
# 3. Install Android SDK dari awal
```

## 🔍 Troubleshooting

### Jika Download Terputus/Berulang:

```bash
# Gunakan wget dengan retry (jika tersedia)
wget --tries=3 --timeout=30 -c URL

# Atau gunakan curl dengan resume
curl -C - -L -o filename.zip URL

# Check network/proxy settings
# Android Studio → Preferences → Appearance & Behavior → System Settings → HTTP Proxy
```

### Jika Permission Denied:

```bash
# Fix permission
sudo chown -R $(whoami) ~/Library/Android/sdk
chmod -R 755 ~/Library/Android/sdk
```

### Jika Masih Error:

1. **Check disk space**: `df -h ~`
2. **Check network**: Test download URL di browser
3. **Check firewall/proxy**: Pastikan tidak memblokir Google servers
4. **Try VPN**: Jika ada network restriction

## ⚠️ Important Notes

- **Ini TIDAK urgent untuk iOS development** - iOS sudah working
- **Android SDK hanya diperlukan untuk build Android**
- **Untuk sekarang**, fokus ke iOS development dulu
- **Android SDK bisa di-fix nanti** saat mau develop untuk Android

## 📝 Quick Fix Checklist

- [ ] Clear Android SDK cache
- [ ] Retry installation via Android Studio
- [ ] Jika gagal, manual download & extract
- [ ] Verify installation dengan `flutter doctor`
- [ ] Accept Android licenses: `flutter doctor --android-licenses`

## 🔴 Error Uninstall: "Uninstall Android SDK Command-line Tools failed"

Jika Anda mengalami error saat mencoba **uninstall** Android SDK Command-line Tools di Android Studio:

```
Preparing "Uninstall Android SDK Command-line Tools (latest) v.19.0.0 rc1".
"Uninstall Android SDK Command-line Tools (latest) v.19.0.0 rc1" failed.
Failed packages:
- Android SDK Command-line Tools (latest) (cmdline-tools;latest)
```

### ✅ Solusi Force Uninstall

#### **Method 1: Via Script Otomatis** (Disarankan)

```bash
cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app
bash fix_android_sdk_uninstall.sh
```

#### **Method 2: Manual Force Remove**

```bash
# 1. Close Android Studio completely
killall -9 "Android Studio" 2>/dev/null || true
killall -9 java gradle 2>/dev/null || true

# 2. Wait a moment
sleep 2

# 3. Remove file locks (macOS)
xattr -cr ~/Library/Android/sdk/cmdline-tools 2>/dev/null || true

# 4. Fix permissions
chmod -R u+w ~/Library/Android/sdk/cmdline-tools 2>/dev/null || true

# 5. Force remove cmdline-tools
rm -rf ~/Library/Android/sdk/cmdline-tools/latest

# 6. If still exists, try with sudo
sudo rm -rf ~/Library/Android/sdk/cmdline-tools/latest

# 7. Remove entire directory if empty
rm -rf ~/Library/Android/sdk/cmdline-tools 2>/dev/null || true
```

#### **Method 3: Via Terminal (Alternative)**

Jika masih gagal, coba:

```bash
# 1. Close all Android Studio instances
pkill -f "Android Studio"

# 2. Find and kill all Java/Gradle processes
pkill -9 java
pkill -9 gradle

# 3. Wait
sleep 3

# 4. Remove with elevated permissions
sudo rm -rf ~/Library/Android/sdk/cmdline-tools

# 5. Verify
ls -la ~/Library/Android/sdk/cmdline-tools 2>/dev/null && echo "Still exists" || echo "Removed successfully"
```

### Setelah Force Remove

1. **Close Android Studio completely**
2. **Reopen Android Studio**
3. **Tools → SDK Manager → SDK Tools**
4. **Install Android SDK Command-line Tools (latest)** fresh

---

**Untuk sekarang, iOS sudah working. Android SDK bisa di-fix nanti saat diperlukan.**
