import 'package:flutter/foundation.dart';

/// API Configuration Constants
class ApiConfig {
  /// Enable API logging
  /// Set to `true` for development/debugging
  /// Set to `false` for production builds
  static const bool enableApiLogging = kDebugMode; // Auto enable in debug mode

  /// You can also manually set this:
  /// static const bool enableApiLogging = true;  // Always enabled
  /// static const bool enableApiLogging = false; // Always disabled
}
