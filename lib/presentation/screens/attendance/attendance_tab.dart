import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/layout/dashboard_tab_bottom_inset.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../../data/models/attendance_model.dart';
import '../../widgets/attendance_list_item.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_glass_scaffold.dart';

/// Attendance Tab - Shows attendance history and current status
/// Based on POS Mobile Figma Template design
class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late List<AttendanceModel> attendanceRecords;

  @override
  void initState() {
    super.initState();
    attendanceRecords = MockDataProvider.sampleAttendanceRecords;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.attendance),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter feature coming soon')),
              );
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: Column(
          children: [
            // Current Status Card
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: LiquidGlassCard(
                borderRadius: AppDimensions.cardRadius,
                child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Status',
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
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
                        ),
                        child: Text(
                          'Working',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
                          'Clock In',
                          attendanceRecords.first.formattedClockIn,
                          Icons.login,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: _buildTimeCard(
                          'Working Hours',
                          '7h 45m',
                          Icons.schedule,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Clock out coming soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Clock Out'),
                    ),
                  ),
                ],
              ),
            ),
            ),

            // Attendance History Section
            Expanded(
              child: LiquidGlassCard(
                borderRadius: AppDimensions.radiusL,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attendance History',
                            style: AppTypography.h6.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View all coming soon'),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),

                    // Attendance List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: dashboardTabScrollBottomPadding(context),
                        ),
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          return AttendanceListItem(
                            attendance: attendanceRecords[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.36),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: AppDimensions.iconM),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            time,
            style: AppTypography.h6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
