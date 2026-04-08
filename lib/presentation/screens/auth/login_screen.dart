import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailFieldError;
  String? _passwordFieldError;

  late final AnimationController _introController;
  late final Animation<double> _logoFade;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;

  static const _logoAsset = 'assets/images/logo_login.png';
  static const _primaryBlue = Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _cardFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
    );
    _cardScale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.emailRequired;
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return l10n.invalidEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
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
    await ref.read(authProvider.notifier).login(email: email, password: password);

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loginState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6FB1FC), Color(0xFFEAF3FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: Image.asset(
                      _logoAsset,
                      height: 112,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business_center_rounded,
                        size: 72,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16365F),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.pleaseLoginOrSignUp,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF16365F).withValues(alpha: 0.72),
                        ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _cardFade,
                    child: ScaleTransition(
                      scale: _cardScale,
                      child: _GlassPanel(
                        child: Column(
                          children: [
                            _GlassButton(
                              onTap: loginState.isLoginBusy
                                  ? null
                                  : _handleGoogleLogin,
                              loading: loginState.isGoogleLoginLoading,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (loginState.isGoogleLoginLoading)
                                    const _Spinner(size: 20)
                                  else
                                    Image.asset(
                                      'assets/icons/google512px.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  const SizedBox(width: 10),
                                  Text(l10n.continueWithGoogle),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _DividerText(text: l10n.or.toUpperCase()),
                            const SizedBox(height: 16),
                            _GlassInputField(
                              label: l10n.email,
                              controller: _emailController,
                              hint: 'name@company.com',
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) {
                                if (_emailFieldError != null) {
                                  setState(() => _emailFieldError = null);
                                }
                              },
                              leading: Icons.mail_outline_rounded,
                            ),
                            if (_emailFieldError != null) ...[
                              const SizedBox(height: 8),
                              _InlineError(message: _emailFieldError!),
                            ],
                            const SizedBox(height: 12),
                            _GlassInputField(
                              label: l10n.password,
                              controller: _passwordController,
                              hint: '••••••••',
                              obscureText: _obscurePassword,
                              onChanged: (_) {
                                if (_passwordFieldError != null) {
                                  setState(() => _passwordFieldError = null);
                                }
                              },
                              leading: Icons.lock_outline_rounded,
                              trailing: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF244D7C)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              onSubmitted: (_) => _handleLogin(),
                            ),
                            if (_passwordFieldError != null) ...[
                              const SizedBox(height: 8),
                              _InlineError(message: _passwordFieldError!),
                            ],
                            const SizedBox(height: 18),
                            _GlassButton(
                              onTap: loginState.isLoginBusy ? null : _handleLogin,
                              loading: loginState.isEmailLoginLoading,
                              filled: true,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (loginState.isEmailLoginLoading) ...[
                                    const _Spinner(size: 20, light: true),
                                    const SizedBox(width: 10),
                                  ],
                                  Text(
                                    l10n.login,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 14),
                spreadRadius: -10,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.child,
    required this.onTap,
    this.loading = false,
    this.filled = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool loading;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final gradient = filled
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5FA5F6), Color(0xFF4A90E2)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.10),
            ],
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onTap,
            child: Ink(
              height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: filled ? 0.18 : 0.26),
                ),
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: filled
                        ? Colors.white
                        : const Color(0xFF1C3F6D).withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassInputField extends StatelessWidget {
  const _GlassInputField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.leading,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData leading;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF1E476F).withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  color: Color(0xFF16365F),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Color(0x884A6D96)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    leading,
                    color: const Color(0xFF244D7C).withValues(alpha: 0.78),
                    size: 20,
                  ),
                  suffixIcon: trailing,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DividerText extends StatelessWidget {
  const _DividerText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.35), height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF1E476F).withValues(alpha: 0.62),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.35), height: 1),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFD64545), size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB73737),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({required this.size, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CupertinoActivityIndicator(
        radius: size * 0.40,
        color: light ? Colors.white : const Color(0xFF2D6FB7),
      ),
    );
  }
}
