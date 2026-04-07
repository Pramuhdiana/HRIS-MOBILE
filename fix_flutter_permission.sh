#!/bin/bash

# Script to fix Flutter permission issues after upgrade
# Run this script from terminal: bash fix_flutter_permission.sh

FLUTTER_PATH="/Users/developer/Documents/developer_sanivokasi/aplikasi/flutter"

echo "🔧 Fixing Flutter permissions..."

# 1. Fix binary permissions
echo "1. Fixing binary permissions..."
chmod +x "$FLUTTER_PATH/bin/flutter"
chmod +x "$FLUTTER_PATH/bin/dart"

# 2. Remove quarantine attributes
echo "2. Removing quarantine attributes..."
xattr -d com.apple.quarantine "$FLUTTER_PATH/bin/flutter" 2>/dev/null || echo "  ✓ No quarantine attribute"
xattr -d com.apple.quarantine "$FLUTTER_PATH/bin/dart" 2>/dev/null || echo "  ✓ No quarantine attribute"

# 3. Fix directory permissions
echo "3. Fixing directory permissions..."
chmod -R 755 "$FLUTTER_PATH/bin"
chmod -R 755 "$FLUTTER_PATH/packages/flutter_tools/bin"

# 4. Verify Flutter works
echo "4. Verifying Flutter..."
"$FLUTTER_PATH/bin/flutter" --version

echo ""
echo "✅ Permission fix completed!"
echo ""
echo "Next steps:"
echo "  cd /Users/developer/Documents/developer_sanivokasi/GitHub/HRIS-MOBILE/hris_mobile_app"
echo "  flutter clean"
echo "  flutter pub get"
echo "  cd ios && pod install && cd .."
echo "  flutter run -d ios"
