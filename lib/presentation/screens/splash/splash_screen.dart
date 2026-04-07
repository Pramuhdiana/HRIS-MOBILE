import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_session_restore.dart';

/// Splash — masuk halus, keluar “portal” (logo membesar + cahaya) lalu navigasi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _bgAsset = 'assets/images/bg-login.jpg';
  static const _logoAsset = 'assets/images/logo_splash_screen.png';

  late AnimationController _c;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _loaderOpacity;
  late Animation<double> _footerOpacity;

  late AnimationController _exit;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.22, 0.65, curve: Curves.easeOut),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.45, 0.82, curve: Curves.easeOut),
    );
    _footerOpacity = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1080),
    );

    _c.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapAndNavigate());
  }

  Future<void> _bootstrapAndNavigate() async {
    await Future.wait([
      restoreAuthSession(ref),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    if (!mounted) return;

    final seen = await ref.read(hasSeenOnboardingProvider.future);
    if (!mounted) return;

    final loggedIn = ref.read(authTokenProvider) != null;

    final String target;
    if (loggedIn) {
      target = AppRoutes.dashboard;
    } else if (!seen) {
      target = AppRoutes.onboarding;
    } else {
      target = AppRoutes.login;
    }

    await _playPortalExit();
    if (!mounted) return;
    context.go(target);
  }

  Future<void> _playPortalExit() async {
    await _exit.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          // Aksen mesh — pudar saat portal
          AnimatedBuilder(
            animation: Listenable.merge([_c, _exit]),
            builder: (context, _) {
              final chrome = 1.0 -
                  Curves.fastOutSlowIn.transform(_exit.value.clamp(0.0, 1.0));
              return IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: chrome,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.75, -0.55),
                            radius: 1.15,
                            colors: [
                              const Color(0xFF2563EB).withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: chrome,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.85, 0.45),
                            radius: 1.0,
                            colors: [
                              const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Gelap tambahan + “cahaya portal” dari tengah
          AnimatedBuilder(
            animation: _exit,
            builder: (context, _) {
              final t = _exit.value;
              if (t <= 0) return const SizedBox.shrink();
              final eased = Curves.easeInCubic.transform(t);
              return IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42 * eased),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.25 + 1.35 * eased,
                          colors: [
                            Color.lerp(
                                  Colors.white,
                                  const Color(0xFFE8F4FC),
                                  eased,
                                )!
                                .withValues(
                                  alpha: 0.05 + 0.38 * eased * eased,
                                ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXL,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_c, _exit]),
                builder: (context, _) {
                  final exitRaw = _exit.value;
                  final exitT = Curves.easeInCubic.transform(
                    exitRaw.clamp(0.0, 1.0),
                  );
                  final chromeFade = 1.0 -
                      Curves.easeIn.transform(exitRaw.clamp(0.0, 1.0));

                  final baseScale = _logoScale.value;
                  final exitMul = 1.0 + 2.65 * exitT;
                  final totalLogoScale = baseScale * exitMul;
                  final logoOp = (_logoOpacity.value * (1.0 - 0.25 * exitT))
                      .clamp(0.0, 1.0);

                  return Column(
                    children: [
                      const Spacer(flex: 2),
                      Opacity(
                        opacity: logoOp,
                        child: Transform.scale(
                          scale: totalLogoScale,
                          alignment: Alignment.center,
                          child: _LogoWithGlow(asset: _logoAsset),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),
                      Opacity(
                        opacity:
                            (_textOpacity.value * chromeFade).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.appName,
                              style: AppTypography.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              'Human Resource Information System',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                height: 1.35,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      Opacity(
                        opacity:
                            (_loaderOpacity.value * chromeFade).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CupertinoActivityIndicator(
                                        radius: 10,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        l10n?.loading ?? 'Loading…',
                                        style: AppTypography.labelLarge
                                            .copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                          fontWeight: FontWeight.w600,
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
                      SizedBox(height: 32 + bottomInset),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: AppDimensions.paddingL,
            right: AppDimensions.paddingL,
            bottom: 16 + bottomInset,
            child: AnimatedBuilder(
              animation: Listenable.merge([_c, _exit]),
              builder: (context, _) {
                final chromeFade = 1.0 -
                    Curves.easeIn.transform(_exit.value.clamp(0.0, 1.0));
                return Opacity(
                  opacity:
                      (_footerOpacity.value * chromeFade).clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Versi ${AppStrings.appVersion}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '© 2026 HRIS Mobile',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _bgAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ],
                ),
              ),
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoWithGlow extends StatelessWidget {
  const _LogoWithGlow({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            blurRadius: 48,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Image.asset(
        asset,
        height: 150,
        fit: BoxFit.contain,
        semanticLabel: 'HRIS Portal',
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.business_center_rounded,
            size: 72,
            color: Colors.white.withValues(alpha: 0.9),
          );
        },
      ),
    );
  }
}
