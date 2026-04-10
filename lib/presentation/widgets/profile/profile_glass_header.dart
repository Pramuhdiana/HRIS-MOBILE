import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../liquid_glass_card.dart';

/// Reusable profile header with separate back button and title pill.
class ProfileGlassHeader extends StatelessWidget {
  const ProfileGlassHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LiquidGlassCard(
          borderRadius: 999,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.textPrimary,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(
          child: LiquidGlassCard(
            borderRadius: 999,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
