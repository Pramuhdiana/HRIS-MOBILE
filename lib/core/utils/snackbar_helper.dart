import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

import 'liquid_glass_toast.dart';

/// SnackBar Helper
/// Reusable helper for showing awesome snackbars throughout the app
class SnackBarHelper {
  /// Show success snackbar
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
    );
  }

  /// Show error/failure snackbar
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  /// Show warning snackbar
  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
    );
  }

  /// Show help/info snackbar
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    _showSnackBar(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
    );
  }

  /// Internal: toast liquid glass dari atas (ganti SnackBar bawaan).
  static void _showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    LiquidGlassToast.show(
      context,
      title: title,
      message: message,
      type: _toLiquidType(contentType),
    );
  }

  static LiquidToastType _toLiquidType(ContentType t) {
    if (identical(t, ContentType.success)) return LiquidToastType.success;
    if (identical(t, ContentType.failure)) return LiquidToastType.error;
    if (identical(t, ContentType.warning)) return LiquidToastType.warning;
    if (identical(t, ContentType.help)) return LiquidToastType.info;
    return LiquidToastType.info;
  }

  /// Show material banner (alternative to snackbar)
  static void showMaterialBanner(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final materialBanner = MaterialBanner(
      /// Need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }
}
