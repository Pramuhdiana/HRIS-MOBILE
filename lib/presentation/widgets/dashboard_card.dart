import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import 'glass/glass_card.dart';
import 'glass/dashboard_glass_style.dart';

/// Dashboard Card Widget - Reusable card for displaying statistics
/// Based on POS Mobile Figma Template design
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconM,
                  color: color,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimensions.iconXS,
                  color: AppColors.textLight,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
