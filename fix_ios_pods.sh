#!/bin/bash

# Script to fix iOS CocoaPods dependencies issue
# Run this script: bash fix_ios_pods.sh

PROJECT_DIR="/Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app"

echo "🔧 Fixing iOS CocoaPods dependencies..."

cd "$PROJECT_DIR" || exit

# 1. Clean iOS build artifacts
echo "1. Cleaning iOS build artifacts..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/build
rm -rf ios/DerivedData
rm -rf ios/Runner.xcworkspace/xcshareddata
rm -rf ios/Runner.xcworkspace/xcuserdata

# 2. Clean Flutter build
echo "2. Cleaning Flutter build..."
rm -rf build
rm -rf .dart_tool
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# 3. Regenerate Flutter files (ini memerlukan Flutter CLI yang bekerja)
echo "3. Note: If Flutter CLI has permission issues, you need to:"
echo "   - Give Full Disk Access to Terminal/IDE (see FIX_PERMISSION_MACOS.md)"
echo "   - Or run these commands manually after fixing permission:"
echo ""
echo "   flutter pub get"
echo "   cd ios && pod install && cd .."

# 4. If Flutter is accessible, try to regenerate
if command -v flutter &> /dev/null; then
    echo "   ✓ Flutter CLI is accessible, regenerating files..."
    flutter clean
    flutter pub get
    
    # 5. Install CocoaPods
    echo "4. Installing CocoaPods dependencies..."
    cd ios || exit
    pod deintegrate 2>/dev/null || echo "  (No pods to deintegrate)"
    pod cache clean --all 2>/dev/null || echo "  (Pod cache clean skipped)"
    pod install --repo-update
    
    echo ""
    echo "✅ CocoaPods installation completed!"
    echo ""
    echo "Next: Open Xcode and build:"
    echo "  open ios/Runner.xcworkspace"
else
    echo ""
    echo "⚠️  Flutter CLI is not accessible due to permission issues."
    echo ""
    echo "Please fix Flutter permission first (see FIX_PERMISSION_MACOS.md), then run:"
    echo "  flutter pub get"
    echo "  cd ios && pod install && cd .."
fi
