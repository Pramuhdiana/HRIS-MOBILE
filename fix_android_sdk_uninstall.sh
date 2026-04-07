#!/bin/bash

# Script to force uninstall Android SDK Command-line Tools
# Run this script: bash fix_android_sdk_uninstall.sh

ANDROID_SDK_PATH="$HOME/Library/Android/sdk"
CMDLINE_TOOLS_PATH="$ANDROID_SDK_PATH/cmdline-tools"

echo "🔧 Force removing Android SDK Command-line Tools..."

# 1. Stop all Android processes
echo "1. Stopping Android processes..."
killall -9 adb java gradle 2>/dev/null || echo "  (No Android processes running)"
sleep 2

# 2. Check if cmdline-tools exists
if [ ! -d "$CMDLINE_TOOLS_PATH" ]; then
    echo "  ⚠️  cmdline-tools not found at: $CMDLINE_TOOLS_PATH"
    echo "  ✅ Nothing to remove!"
    exit 0
fi

echo "2. Found cmdline-tools at: $CMDLINE_TOOLS_PATH"
ls -la "$CMDLINE_TOOLS_PATH"

# 3. Remove file locks (macOS specific)
echo ""
echo "3. Removing file locks..."
if [ -d "$CMDLINE_TOOLS_PATH/latest" ]; then
    # Remove quarantine attributes
    xattr -cr "$CMDLINE_TOOLS_PATH/latest" 2>/dev/null || echo "  (No quarantine attributes)"
    
    # Fix permissions
    chmod -R u+w "$CMDLINE_TOOLS_PATH" 2>/dev/null || echo "  (Permission already OK)"
fi

# 4. Force remove cmdline-tools
echo ""
echo "4. Force removing cmdline-tools..."
if [ -d "$CMDLINE_TOOLS_PATH/latest" ]; then
    # Try normal remove first
    rm -rf "$CMDLINE_TOOLS_PATH/latest" && echo "  ✅ Removed cmdline-tools/latest" || echo "  ⚠️  Failed to remove, trying force..."
    
    # If still exists, try with sudo (user will be prompted)
    if [ -d "$CMDLINE_TOOLS_PATH/latest" ]; then
        echo "  Trying with elevated permissions..."
        sudo rm -rf "$CMDLINE_TOOLS_PATH/latest" && echo "  ✅ Removed with sudo" || echo "  ❌ Still failed"
    fi
fi

# Remove entire cmdline-tools directory if empty or contains only latest
if [ -d "$CMDLINE_TOOLS_PATH" ]; then
    CONTENTS=$(ls -A "$CMDLINE_TOOLS_PATH" 2>/dev/null)
    if [ -z "$CONTENTS" ] || [ "$CONTENTS" == "latest" ] || [ -z "$(ls -A "$CMDLINE_TOOLS_PATH" 2>/dev/null | grep -v '^latest$')" ]; then
        rm -rf "$CMDLINE_TOOLS_PATH" && echo "  ✅ Removed cmdline-tools directory" || echo "  ⚠️  cmdline-tools directory still exists"
    else
        echo "  ℹ️  cmdline-tools directory contains other files, keeping it"
    fi
fi

# 5. Verify removal
echo ""
echo "5. Verifying removal..."
if [ ! -d "$CMDLINE_TOOLS_PATH/latest" ]; then
    echo "  ✅ cmdline-tools/latest successfully removed!"
    if [ ! -d "$CMDLINE_TOOLS_PATH" ]; then
        echo "  ✅ cmdline-tools directory removed!"
    fi
else
    echo "  ⚠️  cmdline-tools/latest still exists"
    echo "  Try manually:"
    echo "    sudo rm -rf $CMDLINE_TOOLS_PATH"
fi

echo ""
echo "✅ Process completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Close Android Studio completely"
echo "  2. Reopen Android Studio"
echo "  3. Tools → SDK Manager → SDK Tools"
echo "  4. Install Android SDK Command-line Tools (latest)"
echo ""
echo "⚠️  Note: Ini TIDAK urgent untuk iOS development!"
echo "   iOS sudah working. Android SDK bisa di-fix nanti saat diperlukan."
