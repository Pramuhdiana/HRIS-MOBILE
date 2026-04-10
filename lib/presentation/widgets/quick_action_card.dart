import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import 'glass/glass_card.dart';
import 'glass/dashboard_glass_style.dart';

/// Quick Action Card Widget - For dashboard quick actions
/// Based on POS Mobile Figma Template design
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: AppDimensions.cardRadius,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      blurSigma: DashboardGlassStyle.blurSigma,
      borderWidth: DashboardGlassStyle.borderWidth,
      borderOpacity: DashboardGlassStyle.borderOpacity,
      overlayTopOpacity: DashboardGlassStyle.overlayTopOpacity,
      overlayBottomOpacity: DashboardGlassStyle.overlayBottomOpacity,
      shadowOpacity: DashboardGlassStyle.shadowOpacity,
      enableBackdropBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: AppDimensions.iconL, color: color),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
