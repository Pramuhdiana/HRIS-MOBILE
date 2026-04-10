import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/employee_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/layout/dashboard_tab_bottom_inset.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../widgets/language_switcher.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_api_provider.dart';
import '../../providers/user_profile_snapshot_provider.dart';
import '../../widgets/app_smart_refresher.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_glass_scaffold.dart';

/// Profile Tab - Shows user profile and settings
/// Based on POS Mobile Figma Template design
class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();

  static String? _managerDisplayName(
    ProfileApiData? profile,
    EmployeeModel employee,
  ) {
    final fromApi = profile?.leaderName?.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    final m = employee.manager?.trim();
    if (m != null && m.isNotEmpty) return m;
    return null;
  }

  static bool _hasWorkLocation(ProfileApiData? p) {
    if (p == null) return false;
    final site = p.workSiteName?.trim();
    final sched = p.workScheduleLine?.trim();
    final addr = p.workLocationAddress?.trim();
    return (site != null && site.isNotEmpty) ||
        (sched != null && sched.isNotEmpty) ||
        (addr != null && addr.isNotEmpty);
  }

  static bool _leaderKnownFromApi(ProfileApiData? p) =>
      p != null && (p.leaderName?.trim().isNotEmpty ?? false);
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  late final RefreshController _refreshController;
  late final ScrollController _scrollController;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onProfileRefresh() async {
    ref.invalidate(profileApiProvider);
    try {
      await ref.read(profileApiProvider.future);
      if (mounted) _refreshController.refreshCompleted();
    } catch (_) {
      if (mounted) _refreshController.refreshFailed();
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    if (_uploadingPhoto) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked == null || !mounted) return;
      setState(() => _uploadingPhoto = true);
      final ds = ref.read(profileDataSourceProvider);
      await ds.uploadProfilePhoto(photoFilePath: picked.path);
      ref.invalidate(profileApiProvider);
      if (!mounted) return;
      SnackBarHelper.showDataSavedSuccess(context);
    } on Failure catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showError(context, title: l10n.error, message: e.message);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showError(
        context,
        title: l10n.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    if (_uploadingPhoto) return;
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Buka galeri'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Buka kamera'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.cancel),
                onTap: () => Navigator.of(sheetCtx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final employee = MockDataProvider.sampleEmployee;
    final snapAsync = ref.watch(userProfileSnapshotProvider);
    final profileAsync = ref.watch(profileApiProvider);
    final profile = profileAsync.valueOrNull;
    final snap = snapAsync.valueOrNull ?? const UserProfileSnapshot();
    final displayName =
        profile?.name ?? snap.displayName ?? snap.email ?? employee.fullName;
    final emailLine = profile?.email ?? snap.email ?? employee.email;
    final positionLine = profile?.position ?? employee.position;
    final departmentLine = profile?.department ?? employee.department;
    final posDeptLine = <String>[
      if (positionLine.trim().isNotEmpty) positionLine,
      if (departmentLine.trim().isNotEmpty) departmentLine,
    ].join(' · ');
    final loginHint = snap.loginMethod == 'google'
        ? '${l10n.profileLoginWithMethod('Google')}${snap.backendSynced ? '' : l10n.profileLoginGoogleLocalNote}'
        : snap.loginMethod != null
        ? l10n.profileLoginWithMethod(snap.loginMethod!)
        : null;
    final roleBadge = profile?.roleDisplayName?.trim();

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColors.liquidGlassBackdrop,
        scaffoldBackgroundColor: AppColors.liquidGlassBackdrop,
      ),
      child: LiquidGlassScaffold(
        body: AppSmartRefresher(
          controller: _refreshController,
          enablePullUp: false,
          scrollController: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          onRefresh: _onProfileRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: dashboardTabScrollBottomPadding(context),
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Profile header: [GlassCard] — blur di atas gradien scaffold (satu bahasa visual dengan kartu di bawah).
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.paddingL,
                            AppDimensions.paddingS,
                            AppDimensions.paddingL,
                            AppDimensions.paddingS,
                          ),
                          child: GlassCard(
                            borderRadius: AppDimensions.radiusXL,
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingL,
                            ),
                            enableShimmer: false,
                            enableBackdropBlur: false,
                            child: Column(
                              children: [
                                // Profile Picture and Name
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: _uploadingPhoto
                                          ? null
                                          : _showPhotoSourceSheet,
                                      child: Container(
                                        width: AppDimensions.avatarXL,
                                        height: AppDimensions.avatarXL,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 3,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if ((profile?.photoUrl ??
                                                        snap.photoUrl) !=
                                                    null &&
                                                (profile?.photoUrl ??
                                                        snap.photoUrl)!
                                                    .isNotEmpty)
                                              Image.network(
                                                (profile?.photoUrl ??
                                                    snap.photoUrl)!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Center(
                                                      child: Text(
                                                        snap.hasSession
                                                            ? snap.initials
                                                            : employee.initials,
                                                        style: AppTypography.h3
                                                            .copyWith(
                                                              color: AppColors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                              )
                                            else
                                              Center(
                                                child: Text(
                                                  snap.hasSession
                                                      ? snap.initials
                                                      : employee.initials,
                                                  style: AppTypography.h3
                                                      .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            if (_uploadingPhoto)
                                              const ColoredBox(
                                                color: Color(0x66000000),
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2.2,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Material(
                                        color: AppColors.primary,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: _uploadingPhoto
                                              ? null
                                              : _showPhotoSourceSheet,
                                          child: const Padding(
                                            padding: EdgeInsets.all(7),
                                            child: Icon(
                                              Icons.photo_camera_outlined,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppDimensions.paddingM),

                                Text(
                                  displayName,
                                  style: AppTypography.h5.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                if (roleBadge != null &&
                                    roleBadge.isNotEmpty) ...[
                                  const SizedBox(
                                    height: AppDimensions.paddingS,
                                  ),
                                  Chip(
                                    label: Text(
                                      roleBadge,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],

                                const SizedBox(height: AppDimensions.paddingS),

                                if (posDeptLine.isNotEmpty)
                                  Text(
                                    posDeptLine,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                if (emailLine.trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    emailLine,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],

                                if (snap.hasSession && loginHint != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    loginHint,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],

                                const SizedBox(height: AppDimensions.paddingL),

                                // Quick Stats Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                      l10n.employeeId,
                                      profile?.employeeId ??
                                          profile?.nik ??
                                          employee.employeeId,
                                      context,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: AppColors.border.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    _buildStatItem(
                                      l10n.profileYearsOfService,
                                      '${profile?.yearsOfService ?? employee.yearsOfService}',
                                      context,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: AppColors.border.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    _buildStatItem(
                                      l10n.profileStatus,
                                      (profile?.statusEmployee ??
                                              employee.status)
                                          .toUpperCase(),
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

                      if (profile != null &&
                          ProfileTab._hasWorkLocation(profile))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.profileWorkLocation,
                                style: AppTypography.h6.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                              _buildWorkLocationCard(context, profile, l10n),
                              const SizedBox(height: AppDimensions.paddingL),
                            ],
                          ),
                        ),

                      if (profile != null &&
                          (profile.leaderName?.trim().isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.profileManager,
                                style: AppTypography.h6.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                              _buildLeaderCard(context, profile, l10n),
                              if ((profile.teamMemberCount ?? 0) > 1) ...[
                                const SizedBox(height: AppDimensions.paddingS),
                                Text(
                                  l10n.profileTeamCount(
                                    profile.teamMemberCount!,
                                  ),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppDimensions.paddingL),
                            ],
                          ),
                        ),

                      // Profile Information
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.personalInfo,
                              style: AppTypography.h6.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            // Personal Information Cards
                            _buildInfoCard(
                              Icons.email_outlined,
                              l10n.email,
                              profile?.email ?? employee.email,
                              context,
                            ),

                            _buildInfoCard(
                              Icons.phone_outlined,
                              l10n.phoneNumber,
                              profile?.phone ??
                                  employee.phoneNumber ??
                                  l10n.profileNotProvided,
                              context,
                            ),

                            if (profile == null) ...[
                              _buildInfoCard(
                                Icons.business_outlined,
                                l10n.department,
                                employee.department,
                                context,
                              ),
                              _buildInfoCard(
                                Icons.work_outline,
                                l10n.position,
                                employee.position,
                                context,
                              ),
                            ],

                            _buildInfoCard(
                              Icons.calendar_today_outlined,
                              l10n.joinDate,
                              _formatJoinDate(
                                context,
                                profile?.joinDateRaw,
                                employee.joinDate,
                              ),
                              context,
                            ),

                            if (!ProfileTab._leaderKnownFromApi(profile))
                              if (ProfileTab._managerDisplayName(
                                    profile,
                                    employee,
                                  )
                                  case final name?)
                                _buildInfoCard(
                                  Icons.person_outline,
                                  l10n.profileManager,
                                  name,
                                  context,
                                ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Menu Options
                            Text(
                              l10n.profileOptions,
                              style: AppTypography.h6.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            _buildMenuTile(
                              Icons.edit_outlined,
                              l10n.editProfile,
                              l10n.profileEditProfileSubtitle,
                              context,
                              onTap: () async {
                                final result = await context.push(
                                  AppRoutes.editProfile,
                                );
                                if (!context.mounted) return;
                                if (result == true) {
                                  SnackBarHelper.showDataSavedSuccess(context);
                                }
                              },
                            ),

                            _buildMenuTile(
                              Icons.lock_outline,
                              l10n.profileChangePassword,
                              l10n.profileChangePasswordSubtitle,
                              context,
                              onTap: () {
                                SnackBarHelper.showInfo(
                                  context,
                                  title: l10n.info,
                                  message: l10n.profileSnackPasswordComingSoon,
                                );
                              },
                            ),

                            _buildMenuTile(
                              Icons.notifications_outlined,
                              l10n.notifications,
                              l10n.profileNotificationsSubtitle,
                              context,
                              onTap: () {
                                SnackBarHelper.showInfo(
                                  context,
                                  title: l10n.info,
                                  message:
                                      l10n.profileSnackNotificationsComingSoon,
                                );
                              },
                            ),

                            // Language Switcher
                            const LanguageSwitcher(),

                            // Test Onboarding Button (for development/testing)
                            _buildMenuTile(
                              Icons.slideshow_outlined,
                              l10n.profileViewOnboarding,
                              l10n.profileViewOnboardingSubtitle,
                              context,
                              onTap: () => _resetOnboarding(context),
                            ),

                            _buildMenuTile(
                              Icons.settings_outlined,
                              l10n.settings,
                              l10n.profileSettingsSubtitle,
                              context,
                              onTap: () {
                                SnackBarHelper.showInfo(
                                  context,
                                  title: l10n.info,
                                  message: l10n.profileSnackSettingsComingSoon,
                                );
                              },
                            ),

                            _buildMenuTile(
                              Icons.help_outline,
                              l10n.profileHelpSupport,
                              l10n.profileHelpSupportSubtitle,
                              context,
                              onTap: () {
                                SnackBarHelper.showInfo(
                                  context,
                                  title: l10n.info,
                                  message: l10n.profileSnackHelpComingSoon,
                                );
                              },
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showLogoutDialog(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppDimensions.paddingM,
                                  ),
                                ),
                                icon: const Icon(Icons.logout),
                                label: Text(l10n.logout),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkLocationCard(
    BuildContext context,
    ProfileApiData profile,
    AppLocalizations l10n,
  ) {
    final title = profile.workSiteName?.trim();
    final schedule = profile.workScheduleLine?.trim();
    final address = profile.workLocationAddress?.trim();

    return LiquidGlassCard(
      borderRadius: AppDimensions.radiusM,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (schedule != null && schedule.isNotEmpty) ...[
            if (title != null && title.isNotEmpty)
              const SizedBox(height: AppDimensions.paddingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: AppDimensions.iconS,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileWorkSchedule,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        schedule,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (address != null && address.isNotEmpty) ...[
            if ((title != null && title.isNotEmpty) ||
                (schedule != null && schedule.isNotEmpty))
              const SizedBox(height: AppDimensions.paddingM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: AppDimensions.iconS,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    address,
                    style: AppTypography.bodySmall.copyWith(
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderCard(
    BuildContext context,
    ProfileApiData profile,
    AppLocalizations l10n,
  ) {
    final name = profile.leaderName!.trim();
    final role = profile.leaderPosition?.trim();
    final photo = profile.leaderPhotoUrl;

    final initials = _initialsFromName(name);

    return LiquidGlassCard(
      borderRadius: AppDimensions.radiusM,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: photo != null && photo.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      photo,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        initials,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Text(
                    initials,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (role != null && role.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildStatItem(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: LiquidGlassCard(
        borderRadius: AppDimensions.radiusM,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: LiquidGlassCard(
        borderRadius: AppDimensions.radiusM,
        padding: EdgeInsets.zero,
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
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
      ),
    );
  }

  String _formatJoinDate(BuildContext context, String? raw, DateTime fallback) {
    DateTime? dt;
    if (raw != null && raw.isNotEmpty) {
      dt = DateTime.tryParse(raw);
    }
    dt ??= fallback;
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMd(locale).format(dt);
  }

  Future<void> _resetOnboarding(BuildContext context) async {
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
        final l10n = AppLocalizations.of(context)!;
        SnackBarHelper.showError(
          context,
          title: l10n.error,
          message: l10n.profileErrorDetails(e.toString()),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.profileLogoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
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
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}
