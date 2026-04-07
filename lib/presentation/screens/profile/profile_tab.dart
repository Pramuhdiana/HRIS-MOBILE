import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../widgets/language_switcher.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_snapshot_provider.dart';

/// Profile Tab - Shows user profile and settings
/// Based on POS Mobile Figma Template design
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = MockDataProvider.sampleEmployee;
    final snapAsync = ref.watch(userProfileSnapshotProvider);
    final snap = snapAsync.valueOrNull ?? const UserProfileSnapshot();
    final displayName =
        snap.displayName ?? snap.email ?? employee.fullName;
    final subtitlePrimary = snap.email != null
        ? snap.email!
        : '${employee.position} · ${employee.department}';
    final loginHint = snap.loginMethod == 'google'
        ? 'Login: Google${snap.backendSynced ? '' : ' (sesi lokal, API belum sync)'}'
        : snap.loginMethod != null
            ? 'Login: ${snap.loginMethod}'
            : employee.department;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    children: [
                      // Profile Picture and Name
                      Container(
                        width: AppDimensions.avatarXL,
                        height: AppDimensions.avatarXL,
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textOnPrimary,
                            width: 3,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: snap.photoUrl != null &&
                                snap.photoUrl!.isNotEmpty
                            ? Image.network(
                                snap.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    snap.hasSession
                                        ? snap.initials
                                        : employee.initials,
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  snap.hasSession
                                      ? snap.initials
                                      : employee.initials,
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      Text(
                        displayName,
                        style: AppTypography.h5.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppDimensions.paddingS),

                      Text(
                        subtitlePrimary,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        snap.hasSession ? loginHint : employee.position,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (!snap.hasSession)
                        Text(
                          employee.department,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textOnPrimary.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: AppDimensions.paddingL),

                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            'Employee ID',
                            employee.employeeId,
                            context,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.textOnPrimary.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'Years of Service',
                            '${employee.yearsOfService}',
                            context,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.textOnPrimary.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'Status',
                            employee.status.toUpperCase(),
                            context,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Profile Information
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.personalInfo,
                    style: AppTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Personal Information Cards
                  _buildInfoCard(
                    Icons.email_outlined,
                    AppStrings.email,
                    employee.email,
                    context,
                  ),

                  _buildInfoCard(
                    Icons.phone_outlined,
                    AppStrings.phoneNumber,
                    employee.phoneNumber ?? 'Not provided',
                    context,
                  ),

                  _buildInfoCard(
                    Icons.business_outlined,
                    AppStrings.department,
                    employee.department,
                    context,
                  ),

                  _buildInfoCard(
                    Icons.work_outline,
                    AppStrings.position,
                    employee.position,
                    context,
                  ),

                  _buildInfoCard(
                    Icons.calendar_today_outlined,
                    AppStrings.joinDate,
                    '${employee.joinDate.day}/${employee.joinDate.month}/${employee.joinDate.year}',
                    context,
                  ),

                  if (employee.manager != null)
                    _buildInfoCard(
                      Icons.person_outline,
                      'Manager',
                      employee.manager!,
                      context,
                    ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Menu Options
                  Text(
                    'Options',
                    style: AppTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  _buildMenuTile(
                    Icons.edit_outlined,
                    AppStrings.editProfile,
                    'Update your personal information',
                    context,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit profile feature coming soon'),
                        ),
                      );
                    },
                  ),

                  _buildMenuTile(
                    Icons.lock_outline,
                    'Change Password',
                    'Update your account password',
                    context,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change password feature coming soon'),
                        ),
                      );
                    },
                  ),

                  _buildMenuTile(
                    Icons.notifications_outlined,
                    AppStrings.notifications,
                    'Manage notification preferences',
                    context,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings coming soon'),
                        ),
                      );
                    },
                  ),

                  // Language Switcher
                  const LanguageSwitcher(),

                  // Test Onboarding Button (for development/testing)
                  _buildMenuTile(
                    Icons.slideshow_outlined,
                    'View Onboarding',
                    'Test onboarding screens again',
                    context,
                    onTap: () => _resetOnboarding(context, ref),
                  ),

                  _buildMenuTile(
                    Icons.settings_outlined,
                    AppStrings.settings,
                    'App settings and preferences',
                    context,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings feature coming soon'),
                        ),
                      );
                    },
                  ),

                  _buildMenuTile(
                    Icons.help_outline,
                    'Help & Support',
                    'Get help and contact support',
                    context,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & support feature coming soon'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingL),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(AppStrings.logout),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnPrimary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconS,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimensions.iconS,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppDimensions.iconXS,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('has_seen_onboarding', false);

      // Invalidate the provider to refresh the value
      ref.invalidate(hasSeenOnboardingProvider);

      if (context.mounted) {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
