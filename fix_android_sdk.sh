#!/bin/bash

# Script to fix Android SDK installation error "Not in GZIP format"
# Run this script: bash fix_android_sdk.sh

echo "🔧 Fixing Android SDK installation error..."

# 1. Stop Android processes
echo "1. Stopping Android processes..."
killall -9 adb java 2>/dev/null || echo "  (No Android processes running)"

# 2. Clear Android SDK cache
echo "2. Clearing Android SDK cache..."
rm -rf ~/Library/Caches/Android
rm -rf ~/.android/cache
rm -rf ~/.android/download-cache
rm -rf /tmp/android-*
echo "  ✅ Cache cleared"

# 3. Clear Android Studio cache
echo "3. Clearing Android Studio cache..."
rm -rf ~/Library/Application\ Support/Google/AndroidStudio*/caches 2>/dev/null || echo "  (No Android Studio cache found)"
echo "  ✅ Android Studio cache cleared"

# 4. Check Android SDK location
ANDROID_SDK_PATH="$HOME/Library/Android/sdk"
echo ""
echo "4. Checking Android SDK location..."
if [ -d "$ANDROID_SDK_PATH" ]; then
    echo "  ✅ Android SDK found at: $ANDROID_SDK_PATH"
    echo "  Current build-tools:"
    ls -la "$ANDROID_SDK_PATH/build-tools" 2>/dev/null | head -5 || echo "    (No build-tools installed)"
    echo ""
    echo "  Current cmdline-tools:"
    ls -la "$ANDROID_SDK_PATH/cmdline-tools" 2>/dev/null || echo "    (No cmdline-tools installed)"
else
    echo "  ⚠️  Android SDK not found at: $ANDROID_SDK_PATH"
    echo "  Please install Android SDK via Android Studio first"
fi

echo ""
echo "✅ Android SDK cache cleared!"
echo ""
echo "📝 Next steps:"
echo "  1. Open Android Studio"
echo "  2. Tools → SDK Manager"
echo "  3. SDK Tools tab"
echo "  4. Uncheck failed tools → Apply (uninstall)"
echo "  5. Check again → Apply (reinstall)"
echo ""
echo "  OR try manual download (see FIX_ANDROID_SDK.md)"
echo ""
echo "⚠️  Note: Ini TIDAK urgent untuk iOS development!"
echo "   iOS sudah working. Android SDK bisa di-fix nanti saat diperlukan."
