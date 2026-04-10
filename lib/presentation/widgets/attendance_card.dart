import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/models/attendance_model.dart';
import 'glass/glass_card.dart';
import 'glass/dashboard_glass_style.dart';

/// Attendance Card Widget - Shows today's attendance status
/// Based on POS Mobile Figma Template design
class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceCard({super.key, required this.attendance});

  Color get _statusColor {
    switch (attendance.status) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'absent':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusText {
    switch (attendance.status) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return 'Unknown';
    }
  }

  IconData get _statusIcon {
    switch (attendance.status) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppDimensions.cardRadius,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      blurSigma: DashboardGlassStyle.blurSigma,
      borderWidth: DashboardGlassStyle.borderWidth,
      borderOpacity: DashboardGlassStyle.borderOpacity,
      overlayTopOpacity: DashboardGlassStyle.overlayTopOpacity,
      overlayBottomOpacity: DashboardGlassStyle.overlayBottomOpacity,
      shadowOpacity: DashboardGlassStyle.shadowOpacity,
      enableShimmer: true,
      enableWaterRipple: false,
      enableBackdropBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.todayAttendance,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon,
                      size: AppDimensions.iconS,
                      color: _statusColor,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      _statusText,
                      style: AppTypography.labelSmall.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Time Information Row
          Row(
            children: [
              // Clock In
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.clockIn,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      attendance.formattedClockIn,
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.26),
              ),

              // Clock Out
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.clockOut,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      attendance.formattedClockOut,
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Working Hours and Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.workingHours,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    attendance.formattedWorkingHours,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Action Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      SnackBarHelper.showInfo(
                        context,
                        title: 'Info',
                        message: attendance.hasClockOut
                            ? 'Attendance complete for today'
                            : 'Clock out functionality coming soon',
                      );
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            attendance.hasClockOut ? Icons.check : Icons.logout,
                            size: AppDimensions.iconS,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            attendance.hasClockOut ? 'Complete' : 'Clock Out',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
