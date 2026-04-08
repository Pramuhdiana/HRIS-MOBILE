import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/attendance_model.dart';
import 'liquid_glass_card.dart';

/// Attendance List Item Widget - Shows individual attendance record
/// Based on POS Mobile Figma Template design
class AttendanceListItem extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceListItem({super.key, required this.attendance});

  Color get _statusColor {
    switch (attendance.status) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'absent':
        return AppColors.error;
      case 'half_day':
        return AppColors.info;
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
      case 'half_day':
        return 'Half Day';
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
      case 'half_day':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  // String get _formattedDate {
  //   return DateFormat('EEE, MMM d').format(attendance.date);
  // }

  String get _dayName {
    return DateFormat('EEEE').format(attendance.date);
  }

  bool get _isToday {
    final now = DateTime.now();
    return attendance.date.year == now.year &&
        attendance.date.month == now.month &&
        attendance.date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingXS,
      ),
      child: LiquidGlassCard(
        borderRadius: AppDimensions.radiusM,
        borderAlpha: _isToday ? 0.30 : 0.18,
        topAlpha: _isToday ? 0.18 : 0.12,
        bottomAlpha: 0.05,
        shadowAlpha: 0.06,
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            // Date Section
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(attendance.date),
                    style: AppTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isToday
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(attendance.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: _isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (_isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Today',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.paddingM),

            // Attendance Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dayName,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, size: 12, color: _statusColor),
                            const SizedBox(width: 4),
                            Text(
                              _statusText,
                              style: AppTypography.caption.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingS),

                  // Time Information
                  Row(
                    children: [
                      // Clock In
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.login,
                              size: AppDimensions.iconS,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppDimensions.paddingXS),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'In',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  attendance.formattedClockIn,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Clock Out
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: AppDimensions.iconS,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppDimensions.paddingXS),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Out',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  attendance.formattedClockOut,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Working Hours
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: AppDimensions.iconS,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: AppDimensions.paddingXS),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hours',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  attendance.formattedWorkingHours,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Notes (if any)
                  if (attendance.notes != null &&
                      attendance.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.paddingS),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: AppDimensions.iconXS,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Expanded(
                            child: Text(
                              attendance.notes!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
