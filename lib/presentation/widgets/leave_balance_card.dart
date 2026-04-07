import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/leave_model.dart';

/// Leave Balance Card Widget - Shows leave balance for each type
/// Based on POS Mobile Figma Template design
class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalanceModel balance;

  const LeaveBalanceCard({super.key, required this.balance});

  String get _leaveTypeName {
    final type = LeaveType.fromString(balance.leaveType);
    return type.displayName;
  }

  Color get _leaveTypeColor {
    switch (balance.leaveType) {
      case 'annual':
        return AppColors.primary;
      case 'sick':
        return AppColors.error;
      case 'emergency':
        return AppColors.warning;
      case 'maternity':
      case 'paternity':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }

  IconData get _leaveTypeIcon {
    switch (balance.leaveType) {
      case 'annual':
        return Icons.beach_access;
      case 'sick':
        return Icons.local_hospital;
      case 'emergency':
        return Icons.emergency;
      case 'maternity':
        return Icons.pregnant_woman;
      case 'paternity':
        return Icons.child_care;
      default:
        return Icons.event_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = balance.usagePercentage;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: _leaveTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Icon(
                        _leaveTypeIcon,
                        size: AppDimensions.iconM,
                        color: _leaveTypeColor,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _leaveTypeName,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Year ${balance.year}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: _getUsageColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Text(
                    '${percentage.toInt()}% used',
                    style: AppTypography.labelSmall.copyWith(
                      color: _getUsageColor(percentage),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Used: ${balance.usedDays} days',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Remaining: ${balance.remainingDays} days',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingS),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getUsageColor(percentage),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Bottom Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${balance.totalDays}',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Used',
                    '${balance.usedDays}',
                    _getUsageColor(percentage),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Available',
                    '${balance.remainingDays}',
                    AppColors.success,
                  ),
                ),
              ],
            ),

            // Expiry Date (if available)
            if (balance.expiryDate != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: AppDimensions.iconS,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Text(
                      'Expires on ${balance.expiryDate!.day}/${balance.expiryDate!.month}/${balance.expiryDate!.year}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getUsageColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.error;
    } else if (percentage >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }
}
