import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../../presentation/providers/app_providers.dart';
import 'on_boarding_model.dart';

class AnimatedOnboardingScreen extends ConsumerStatefulWidget {
  const AnimatedOnboardingScreen({super.key});

  @override
  ConsumerState<AnimatedOnboardingScreen> createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState
    extends ConsumerState<AnimatedOnboardingScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  List<OnBoardingModel> _getOnboardingItems(AppLocalizations l10n) {
    return [
      OnBoardingModel(
        title: l10n.welcomeToHRIS,
        subtitle: l10n.welcomeDescription,
        lottieAssetPath:
            'assets/images/onboarding/slide1-j.json', // Lottie animation
      ),
      OnBoardingModel(
        title: l10n.trackAttendanceTitle,
        subtitle: l10n.trackAttendanceDescription,
        lottieAssetPath:
            'assets/images/onboarding/slide2-j.json', // Lottie animation
      ),
      OnBoardingModel(
        title: l10n.manageLeavesTitle,
        subtitle: l10n.manageLeavesDescription,
        lottieAssetPath:
            'assets/images/onboarding/slide3-j-2.json', // Lottie animation
      ),
    ];
  }

  Future<void> _navigateToLogin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_seen_onboarding', true);
    ref.invalidate(hasSeenOnboardingProvider);
    await ref.read(hasSeenOnboardingProvider.future);

    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    final items = _getOnboardingItems(l10n);

    // Slide terakhir: navigasi tidak butuh PageController — jangan return di bawah
    // `!hasClients` atau tombol selesai terasa “tidak merespons”.
    if (currentIndex >= items.length - 1) {
      _navigateToLogin();
      return;
    }

    if (!pageController.hasClients) return;

    pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubicEmphasized, // Smooth curve
    );
  }

  Widget _buildPageContent(OnBoardingModel item, int index) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        // Saat frame pertama `page` sering null → tanpa fallback opacity teks jadi 0.
        final double pageFloat = pageController.hasClients &&
                pageController.position.haveDimensions
            ? (pageController.page ?? currentIndex.toDouble())
            : currentIndex.toDouble();
        double value = pageFloat - index;
        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);

        // Smooth fade and slide animation
        final opacity = value.clamp(0.0, 1.0);
        final slideOffset = (1 - opacity) * 50;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideOffset),
            child: Transform.scale(
              scale: 0.8 + (opacity * 0.2), // Scale from 0.8 to 1.0
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimationWidget(OnBoardingModel item) {
    // Priority: Lottie Asset > Lottie Network > Image Asset
    if (item.lottieAssetPath != null) {
      // Lottie animation from local asset
      return SizedBox(
        width: 400,
        height: 400,
        child: Lottie.asset(
          item.lottieAssetPath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading Lottie: ${item.lottieAssetPath}');
            debugPrint('Error: $error');
            return Center(
              child: Icon(
                Icons.animation,
                size: 100,
                color: AppColors.textSecondary,
              ),
            );
          },
        ),
      );
    } else if (item.lottieURL != null) {
      // Lottie animation from network
      return SizedBox(
        width: 500,
        height: 400,
        child: Lottie.network(
          item.lottieURL!,
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      );
    } else if (item.imagePath != null) {
      // Regular image (PNG/JPG)
      return SizedBox(
        width: 400,
        height: 400,
        child: Image.asset(
          item.imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: ${item.imagePath}');
            debugPrint('Error: $error');
            return Center(
              child: Icon(
                Icons.image_not_supported,
                size: 100,
                color: AppColors.textSecondary,
              ),
            );
          },
        ),
      );
    } else {
      // Fallback
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _getOnboardingItems(l10n);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            painter: ArcPaint(),
            child: SizedBox(height: size.height / 1.35, width: size.width),
          ),
          // Image atau Lottie animation dengan smooth transition
          AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double value = 0.0;
              // Check if PageController is attached and has dimensions
              if (pageController.hasClients &&
                  pageController.position.haveDimensions) {
                final page = pageController.page;
                if (page != null) {
                  value = page - currentIndex;
                }
              }

              // Smooth fade and scale animation untuk gambar/animasi
              final opacity = (1 - value.abs() * 2).clamp(0.0, 1.0);
              final scale = 0.9 + (opacity * 0.1); // Scale from 0.9 to 1.0
              final slideOffset = value * 50; // Slide effect

              // Only show if opacity is significant (avoid showing multiple images)
              if (opacity < 0.1) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: 120,
                right: 0,
                left: 0,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.translate(
                      offset: Offset(slideOffset, 0),
                      child: _buildAnimationWidget(items[currentIndex]),
                    ),
                  ),
                ),
              );
            },
          ),
          // Content section
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildPageContent(item, index);
                      },
                      onPageChanged: (value) {
                        setState(() {
                          currentIndex = value;
                        });
                      },
                    ),
                  ),
                  // Dot indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < items.length; index++)
                        dotIndicator(isSelected: index == currentIndex),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Small arrow / selesai — area ketukan diperlebar (min 48) agar mudah diklik
          Positioned(
            bottom: 40,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _nextPage,
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    currentIndex == items.length - 1
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dotIndicator({required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isSelected ? 10 : 8,
        width: isSelected ? 10 : 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}

class ArcPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Orange arc (background)
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 175)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 175,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(orangeArc, Paint()..color = AppColors.primary);

    // Light blue arc (overlay)
    Path whiteArc = Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, size.height - 180)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 60,
        size.width,
        size.height - 180,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      whiteArc,
      Paint()..color = AppColors.primaryLight.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
