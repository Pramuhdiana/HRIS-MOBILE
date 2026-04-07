import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/routes/app_router.dart';
import '../../providers/auth_provider.dart';

/// Login — tema glassmorphism (iOS-style frosted glass) di atas latar foto.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailFieldError;
  String? _passwordFieldError;

  static const _bgAsset = 'assets/images/bg-login.jpg';
  static const _logoAsset = 'assets/images/logo_login.png';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final eErr = _validateEmail(email);
    final pErr = _validatePassword(password);
    setState(() {
      _emailFieldError = eErr;
      _passwordFieldError = pErr;
    });
    if (eErr != null || pErr != null) return;

    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;
    final loginState = ref.read(authProvider);
    final l10n = AppLocalizations.of(context)!;

    if (loginState.error != null) {
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: loginState.error!,
      );
    } else if (loginState.token != null) {
      context.go(AppRoutes.dashboard, extra: AppRoutes.extraLoginSuccess);
    }
  }

  Future<void> _handleGoogleLogin() async {
    ref.read(authProvider.notifier).clearError();
    await ref.read(authProvider.notifier).loginWithGoogle();

    if (!mounted) return;
    final loginState = ref.read(authProvider);
    final l10n = AppLocalizations.of(context)!;

    if (loginState.error != null) {
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: loginState.error!,
      );
    } else if (loginState.token != null) {
      context.go(AppRoutes.dashboard, extra: AppRoutes.extraLoginSuccess);
    }
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.emailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return l10n.invalidEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loginState = ref.watch(authProvider);

    final labelStyle = AppTypography.labelLarge.copyWith(
      color: Colors.white.withValues(alpha: 0.75),
      fontWeight: FontWeight.w600,
    );
    final fieldStyle = AppTypography.bodyLarge.copyWith(color: Colors.white);
    final hintStyle = AppTypography.bodyLarge.copyWith(
      color: Colors.white.withValues(alpha: 0.45),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.paddingL),
                  Center(
                    child: Image.asset(
                      _logoAsset,
                      height: 180,
                      fit: BoxFit.contain,
                      semanticLabel: 'HRIS Portal',
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'HRIS Portal',
                          textAlign: TextAlign.center,
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXS),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    l10n.email.split(' ').isNotEmpty
                        ? 'Akses sistem secara cepat dan efisien dalam satu sentuhan'
                        : 'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  _GlassButton(
                    onTap: loginState.isLoginBusy ? null : _handleGoogleLogin,
                    isLoading: loginState.isGoogleLoginLoading,
                    extraTranslucent: true,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: loginState.isGoogleLoginLoading
                              ? const _GlassPrimarySpinner(size: 24)
                              : Image.asset(
                                  'assets/icons/google512px.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: Text(
                            l10n.continueWithGoogle,
                            style: AppTypography.h6.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  _buildOrDivider(),

                  const SizedBox(height: AppDimensions.paddingL),

                  Text(l10n.email, style: labelStyle),
                  const SizedBox(height: AppDimensions.paddingS),
                  _GlassInput(
                    extraTranslucent: true,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (_) {
                        if (_emailFieldError != null) {
                          setState(() => _emailFieldError = null);
                        }
                      },
                      style: fieldStyle,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'name@company.com',
                        hintStyle: hintStyle,
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingM,
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ),
                  if (_emailFieldError != null) ...[
                    const SizedBox(height: 10),
                    _LoginFieldError(message: _emailFieldError!),
                  ],

                  const SizedBox(height: AppDimensions.paddingL),

                  Text(l10n.password, style: labelStyle),
                  const SizedBox(height: AppDimensions.paddingS),
                  _GlassInput(
                    extraTranslucent: true,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (_) {
                        if (_passwordFieldError != null) {
                          setState(() => _passwordFieldError = null);
                        }
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                      style: fieldStyle,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: hintStyle,
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: AppDimensions.paddingM,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.white.withValues(
                                alpha: 0.85,
                              ),
                              minimumSize: const Size(44, 44),
                              padding: EdgeInsets.zero,
                            ),
                            tooltip: _obscurePassword
                                ? 'Tampilkan password'
                                : 'Sembunyikan password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 22,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ),
                  if (_passwordFieldError != null) ...[
                    const SizedBox(height: 10),
                    _LoginFieldError(message: _passwordFieldError!),
                  ],

                  const SizedBox(height: AppDimensions.paddingM),

                  Row(
                    children: [
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: loginState.isLoginBusy
                              ? null
                              : (v) => setState(() => _rememberMe = v ?? false),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          fillColor: WidgetStateProperty.resolveWith((s) {
                            if (s.contains(WidgetState.selected)) {
                              return Colors.white.withValues(alpha: 0.35);
                            }
                            return Colors.transparent;
                          }),
                          checkColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.rememberMe,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: loginState.isLoginBusy
                            ? null
                            : () {
                                SnackBarHelper.showInfo(
                                  context,
                                  title: l10n.forgotPassword,
                                  message:
                                      'Silakan hubungi tim HR untuk reset password.',
                                );
                              },
                        child: Text(
                          l10n.forgotPassword,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  _GlassButton(
                    onTap: loginState.isLoginBusy ? null : _handleLogin,
                    isLoading: loginState.isEmailLoginLoading,
                    highlight: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (loginState.isEmailLoginLoading) ...[
                          const _GlassPrimarySpinner(size: 22),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          l10n.login,
                          style: AppTypography.h6.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXXL),

                  Text(
                    'Dengan melanjutkan, Anda menyetujui ketentuan layanan '
                    'terkait HRIS perusahaan Anda.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      _bgAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
          ),
          child: Text(
            AppLocalizations.of(context)!.or.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
      ],
    );
  }
}

/// Pesan validasi di bawah field (di luar pill glass) agar rapi dan mudah dibaca.
class _LoginFieldError extends StatelessWidget {
  const _LoginFieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x66FF9A8A), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0x59FF6B6B),
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Color(0xFFFFE0E0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indikator loading beranimasi (rotasi iOS-style), lebih terlihat “bergerak” di atas glass.
class _GlassPrimarySpinner extends StatelessWidget {
  const _GlassPrimarySpinner({this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = (size * 0.42).clamp(8.0, 14.0);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: radius,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

/// Satu tempat mengatur tampilan “extra translucency” (tombol Google & [_GlassInput]).
abstract final class _LoginGlassExtraTier {
  static const borderAlpha = 0.10;
  static const gradientTop = 0.1;
  static const gradientBottom = 0.035;
  static const blurSigma = 2.0;
}

/// Input glass — pill & blur; [extraTranslucent] memakai [_LoginGlassExtraTier].
class _GlassInput extends StatelessWidget {
  const _GlassInput({required this.child, this.extraTranslucent = false});

  final Widget child;
  final bool extraTranslucent;

  @override
  Widget build(BuildContext context) {
    final borderAlpha = extraTranslucent
        ? _LoginGlassExtraTier.borderAlpha
        : 0.3;
    final gradientColors = extraTranslucent
        ? [
            Colors.white.withValues(alpha: _LoginGlassExtraTier.gradientTop),
            Colors.white.withValues(alpha: _LoginGlassExtraTier.gradientBottom),
          ]
        : [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.08),
          ];
    final blurSigma = extraTranslucent ? _LoginGlassExtraTier.blurSigma : 14.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderAlpha),
            ),
            gradient: LinearGradient(colors: gradientColors),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tombol kaca pill (tinggi seragam dengan CTA).
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.child,
    required this.onTap,
    this.isLoading = false,
    this.highlight = false,
    this.extraTranslucent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool highlight;

  /// Lapisan putih lebih tipis agar lebih tembus pandang (mis. tombol Google).
  final bool extraTranslucent;

  @override
  Widget build(BuildContext context) {
    final borderAlpha = highlight
        ? 0.42
        : extraTranslucent
        ? _LoginGlassExtraTier.borderAlpha
        : 0.3;
    final gradientColors = highlight
        ? [
            Colors.white.withValues(alpha: extraTranslucent ? 0.26 : 0.32),
            Colors.white.withValues(alpha: extraTranslucent ? 0.1 : 0.14),
          ]
        : extraTranslucent
        ? [
            Colors.white.withValues(alpha: _LoginGlassExtraTier.gradientTop),
            Colors.white.withValues(alpha: _LoginGlassExtraTier.gradientBottom),
          ]
        : [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.08),
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: extraTranslucent ? _LoginGlassExtraTier.blurSigma : 14,
          sigmaY: extraTranslucent ? _LoginGlassExtraTier.blurSigma : 14,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: borderAlpha),
                ),
                gradient: LinearGradient(colors: gradientColors),
              ),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
