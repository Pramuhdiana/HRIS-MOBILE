import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/leave_model.dart';

/// Leave List Item Widget - Shows individual leave request
/// Based on POS Mobile Figma Template design
class LeaveListItem extends StatelessWidget {
  final LeaveModel leave;
  final VoidCallback? onTap;

  const LeaveListItem({super.key, required this.leave, this.onTap});

  Color get _statusColor {
    switch (leave.status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (leave.status) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  Color get _leaveTypeColor {
    switch (leave.leaveType) {
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
    switch (leave.leaveType) {
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

  String get _leaveTypeName {
    final type = LeaveType.fromString(leave.leaveType);
    return type.displayName;
  }

  String get _formattedDateRange {
    final formatter = DateFormat('MMM d');
    final start = formatter.format(leave.startDate);
    final end = formatter.format(leave.endDate);

    if (leave.startDate.year == leave.endDate.year &&
        leave.startDate.month == leave.endDate.month &&
        leave.startDate.day == leave.endDate.day) {
      return formatter.format(leave.startDate);
    }

    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
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
                            size: AppDimensions.iconS,
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
                              _formattedDateRange,
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
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon,
                            size: AppDimensions.iconXS,
                            color: _statusColor,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            leave.statusText,
                            style: AppTypography.labelSmall.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Duration and Days Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: AppDimensions.iconS,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Text(
                            '${leave.totalDays} day${leave.totalDays > 1 ? 's' : ''}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (leave.isEmergency)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 10,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Emergency',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Reason
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: AppDimensions.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Expanded(
                        child: Text(
                          leave.reason,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Approval Info (if approved)
                if (leave.isApproved && leave.approvedBy != null) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: AppDimensions.iconS,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Approved by ${leave.approvedBy}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (leave.approvedAt != null)
                        Text(
                          DateFormat('MMM d, y').format(leave.approvedAt!),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],

                // Rejection Reason (if rejected)
                if (leave.isRejected && leave.rejectionReason != null) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: AppDimensions.iconS,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason:',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                leave.rejectionReason!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Attachments (if any)
                if (leave.attachments != null &&
                    leave.attachments!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: AppDimensions.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        '${leave.attachments!.length} attachment${leave.attachments!.length > 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // Applied Date
                const SizedBox(height: AppDimensions.paddingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied on ${DateFormat('MMM d, y').format(leave.appliedAt)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textLight,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
