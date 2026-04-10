import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_glass_scaffold.dart';
import '../../widgets/profile/profile_glass_header.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.passwordRequired;
    if (value.trim().length < 6) return l10n.passwordTooShort;
    return null;
  }

  String? _validateConfirm(String? value, AppLocalizations l10n) {
    final base = _validateRequired(value, l10n);
    if (base != null) return base;
    if ((value ?? '').trim() != _newController.text.trim()) {
      final isId = Localizations.localeOf(context).languageCode == 'id';
      return isId
          ? 'Konfirmasi kata sandi baru tidak sama.'
          : 'New password confirmation does not match.';
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final ds = ref.read(authDataSourceProvider);
      await ds.changePassword(
        currentPassword: _currentController.text.trim(),
        newPassword: _newController.text.trim(),
        newConfirmPassword: _confirmController.text.trim(),
      );
      if (!mounted) return;
      final isId = Localizations.localeOf(context).languageCode == 'id';
      SnackBarHelper.showSuccess(
        context,
        title: l10n.success,
        message: isId
            ? 'Kata sandi berhasil diperbarui.'
            : 'Password changed successfully.',
      );
      context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: e.message.split('\n').first.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isId = Localizations.localeOf(context).languageCode == 'id';

    return LiquidGlassScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileGlassHeader(
                title: l10n.profileChangePassword,
                onBack: () => context.pop(),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Form(
                key: _formKey,
                child: LiquidGlassCard(
                  borderRadius: AppDimensions.radiusXL,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.profileChangePasswordSubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                      TextFormField(
                        controller: _currentController,
                        obscureText: _hideCurrent,
                        validator: (v) => _validateRequired(v, l10n),
                        decoration: InputDecoration(
                          labelText:
                              isId ? 'Kata sandi lama' : 'Current password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideCurrent = !_hideCurrent),
                            icon: Icon(
                              _hideCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      TextFormField(
                        controller: _newController,
                        obscureText: _hideNew,
                        validator: (v) => _validateRequired(v, l10n),
                        decoration: InputDecoration(
                          labelText: isId ? 'Kata sandi baru' : 'New password',
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hideNew = !_hideNew),
                            icon: Icon(
                              _hideNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _hideConfirm,
                        validator: (v) => _validateConfirm(v, l10n),
                        decoration: InputDecoration(
                          labelText: isId
                              ? 'Konfirmasi kata sandi baru'
                              : 'Confirm new password',
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            icon: Icon(
                              _hideConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary,
                              AppColors.primary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                            ),
                          ),
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(_saving ? l10n.profileSaving : l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
