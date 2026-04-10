import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/layout/dashboard_tab_bottom_inset.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../../data/models/leave_model.dart';
import '../../widgets/leave_balance_card.dart';
import '../../widgets/leave_list_item.dart';
import '../../widgets/app_smart_refresher.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_glass_scaffold.dart';

/// Leave Tab - Shows leave balance and leave history
/// Based on POS Mobile Figma Template design
class LeaveTab extends StatefulWidget {
  const LeaveTab({super.key});

  @override
  State<LeaveTab> createState() => _LeaveTabState();
}

class _LeaveTabState extends State<LeaveTab> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<LeaveModel> leaveRecords;
  late List<LeaveBalanceModel> leaveBalances;
  late final RefreshController _balanceRefreshController;
  late final RefreshController _historyRefreshController;
  late final ScrollController _balanceScrollController;
  late final ScrollController _historyScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    leaveRecords = MockDataProvider.sampleLeaveRecords;
    leaveBalances = MockDataProvider.sampleLeaveBalances;
    _balanceRefreshController = RefreshController(initialRefresh: false);
    _historyRefreshController = RefreshController(initialRefresh: false);
    _balanceScrollController = ScrollController();
    _historyScrollController = ScrollController();
  }

  @override
  void dispose() {
    _balanceRefreshController.dispose();
    _historyRefreshController.dispose();
    _balanceScrollController.dispose();
    _historyScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefreshBalance() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) _balanceRefreshController.refreshCompleted();
  }

  Future<void> _onRefreshHistory() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) _historyRefreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leave),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              SnackBarHelper.showComingSoon(
                context,
                feature: 'Apply leave feature',
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelMedium,
          tabs: const [
            Tab(text: 'Balance'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBalanceTab(), _buildHistoryTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          SnackBarHelper.showComingSoon(
            context,
            feature: 'Apply leave feature',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBalanceTab() {
    return AppSmartRefresher(
      controller: _balanceRefreshController,
      scrollController: _balanceScrollController,
      enablePullUp: false,
      onRefresh: _onRefreshBalance,
      child: SingleChildScrollView(
        controller: _balanceScrollController,
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingL,
          AppDimensions.paddingL,
          AppDimensions.paddingL,
          AppDimensions.paddingL + dashboardTabScrollBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            LiquidGlassCard(
              borderRadius: AppDimensions.cardRadius,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave Year ${DateTime.now().year}',
                          style: AppTypography.h6.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          'Plan your time off wisely',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      size: AppDimensions.iconL,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Leave Balance Cards
            Text(
              AppStrings.leaveBalance,
              style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            ...leaveBalances.map(
              (balance) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: LeaveBalanceCard(balance: balance),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Quick Stats
            LiquidGlassCard(
              borderRadius: AppDimensions.cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Leave',
                          '36 days',
                          Icons.event_available,
                          AppColors.info,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Used',
                          '11 days',
                          Icons.event_busy,
                          AppColors.warning,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Remaining',
                          '25 days',
                          Icons.event_note,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return AppSmartRefresher(
      controller: _historyRefreshController,
      scrollController: _historyScrollController,
      enablePullUp: false,
      onRefresh: _onRefreshHistory,
      child: CustomScrollView(
        controller: _historyScrollController,
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: LiquidGlassCard(
                borderRadius: AppDimensions.radiusM,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: AppDimensions.iconS,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Text(
                              'Search leave requests...',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        size: AppDimensions.iconS,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (leaveRecords.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      AppStrings.noData,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: leaveRecords.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    index == 0 ? 0 : AppDimensions.paddingS,
                    AppDimensions.paddingL,
                    index == leaveRecords.length - 1
                        ? AppDimensions.paddingL +
                              dashboardTabScrollBottomPadding(context)
                        : 0,
                  ),
                  child: LeaveListItem(
                    leave: leaveRecords[index],
                    onTap: () {
                      SnackBarHelper.showComingSoon(
                        context,
                        feature: 'Leave details',
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, size: AppDimensions.iconM, color: color),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
