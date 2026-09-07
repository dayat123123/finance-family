import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/transaction.dart';
import 'add_transaction_page.dart';
import 'transaction_detail_page.dart';
import 'manage_goals_page.dart';
import 'manage_budget_page.dart';
import 'weekly_expense_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchQuery = '';
  Actor? _selectedActorFilter;
  TransactionType? _selectedTypeFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: LiquidGlassBackground(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: LiquidGlassTheme.primaryViolet,
                ),
              );
            }

            if (state is FinanceLoaded) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeaderAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelector(context, state),
                          const SizedBox(height: 16),
                          _buildMainHeroCard(state, format),
                          const SizedBox(height: 24),
                          // New Feature: Family Financial Health & Smart Insights
                          _buildFinancialHealthCard(state, format),
                          const SizedBox(height: 28),
                          _buildGoalsSection(context, state, format),
                          const SizedBox(height: 28),
                          if (state.monthlyExpense > 0) ...[
                            _buildWeeklyExpenseSummary(state, format),
                            const SizedBox(height: 28),
                          ],
                          _buildBudgetPlansSection(context, state, format),
                          const SizedBox(height: 28),
                          if (state.monthlyExpense > 0) ...[
                            _buildSectionTitle(
                              'Distribusi Pengeluaran',
                              icon: Icons.pie_chart_rounded,
                              iconColor: LiquidGlassTheme.secondaryCyan,
                            ),
                            const SizedBox(height: 14),
                            _buildModernChart(
                                state.monthlyTransactions, format),
                            const SizedBox(height: 28),
                          ],
                          _buildTransactionSection(
                              context, state.monthlyTransactions, format),
                          const SizedBox(height: 130),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionDock(context),
    );
  }

  Widget _buildHeaderAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 85,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LiquidGlassTheme.primaryLiquidGradient,
                          boxShadow: [
                            BoxShadow(
                              color: LiquidGlassTheme.primaryViolet
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Keuangan Keluarga',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: LiquidGlassTheme.surplusEmerald,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Hidayatullah & Deasy',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                const SizedBox(width: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FamilyActorBadge(
                      fullName: 'Hidayatullah',
                      size: 32,
                    ),
                    SizedBox(width: 6),
                    FamilyActorBadge(
                      fullName: 'Deasy Amalia W.',
                      size: 32,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title,
      {IconData? icon, Color? iconColor, Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: iconColor ?? LiquidGlassTheme.primaryViolet,
                    size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context, FinanceLoaded state) {
    final monthName =
        DateFormat('MMMM yyyy', 'id_ID').format(state.selectedMonth);

    return Center(
      child: LiquidGlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
        onTap: () => _showMonthYearPicker(context, state.selectedMonth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: LiquidGlassTheme.primaryViolet.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: LiquidGlassTheme.primaryVioletLight,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              monthName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context, DateTime current) {
    int selectedYear = current.year;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return LiquidGlassContainer(
              borderRadius: 32,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pilih Bulan & Tahun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Year Selector
                    LiquidGlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LiquidGlassIconButton(
                            size: 34,
                            icon: Icons.chevron_left_rounded,
                            onPressed: () {
                              setStateModal(() => selectedYear--);
                            },
                          ),
                          Text(
                            '$selectedYear',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: LiquidGlassTheme.secondaryCyan,
                            ),
                          ),
                          LiquidGlassIconButton(
                            size: 34,
                            icon: Icons.chevron_right_rounded,
                            onPressed: () {
                              setStateModal(() => selectedYear++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Month Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final isSelected = current.year == selectedYear &&
                            current.month == index + 1;
                        return GestureDetector(
                          onTap: () {
                            context.read<FinanceBloc>().add(ChangeMonthEvent(
                                DateTime(selectedYear, index + 1)));
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LiquidGlassTheme.primaryLiquidGradient
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMainHeroCard(FinanceLoaded state, NumberFormat format) {
    Color netColor;
    String statusText;
    IconData statusIcon;

    switch (state.cashFlowStatus) {
      case CashFlowStatus.surplus:
        netColor = LiquidGlassTheme.surplusEmerald;
        statusText = 'Surplus (Hemat)';
        statusIcon = Icons.trending_up_rounded;
        break;
      case CashFlowStatus.defisit:
        netColor = LiquidGlassTheme.defisitRose;
        statusText = 'Defisit (Boros)';
        statusIcon = Icons.trending_down_rounded;
        break;
      case CashFlowStatus.balance:
        netColor = LiquidGlassTheme.balanceAqua;
        statusText = 'Seimbang';
        statusIcon = Icons.balance_rounded;
        break;
    }

    return LiquidGlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          LiquidGlassTheme.primaryViolet.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.02),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TOTAL SALDO AKTIF',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              LiquidGlassBadge(
                label: statusText,
                color: netColor,
                icon: statusIcon,
                isGlowing: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Grand Total Balance
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              format.format(state.currentBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Net Balance Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Saldo Bersih Bulan Ini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    format.format(state.monthlyNetBalance),
                    style: TextStyle(
                      color: netColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Income and Expense Dual Stats Sub-cards
          Row(
            children: [
              Expanded(
                child: _buildLiquidStatPill(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  amount: format.format(state.monthlyIncome),
                  gradient: LiquidGlassTheme.surplusLiquidGradient,
                  textColor: LiquidGlassTheme.surplusEmerald,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLiquidStatPill(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  amount: format.format(state.monthlyExpense),
                  gradient: LiquidGlassTheme.defisitLiquidGradient,
                  textColor: LiquidGlassTheme.defisitRose,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLiquidStatPill({
    required IconData icon,
    required String label,
    required String amount,
    required Gradient gradient,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FEATURE: Family Financial Health Score & Smart Advisor
  Widget _buildFinancialHealthCard(FinanceLoaded state, NumberFormat format) {
    // Dynamic Health Calculation
    double savingsRate = state.monthlyIncome > 0
        ? (state.monthlyNetBalance / state.monthlyIncome).clamp(0.0, 1.0)
        : 0.0;

    int score = 50; // Base score
    if (state.monthlyIncome > 0) {
      score = (savingsRate * 50 +
              (state.cashFlowStatus == CashFlowStatus.surplus
                  ? 30
                  : (state.cashFlowStatus == CashFlowStatus.balance ? 15 : 0)) +
              (state.goals.isNotEmpty ? 15 : 5))
          .clamp(10, 99)
          .toInt();
    } else if (state.currentBalance > 0) {
      score = 75;
    }

    String healthStatus;
    Color healthColor;
    if (score >= 80) {
      healthStatus = 'Sangat Sehat (Optimal)';
      healthColor = LiquidGlassTheme.surplusEmerald;
    } else if (score >= 60) {
      healthStatus = 'Sehat (Terkendali)';
      healthColor = LiquidGlassTheme.secondaryCyan;
    } else {
      healthStatus = 'Perlu Perhatian';
      healthColor = LiquidGlassTheme.amberWarning;
    }

    // Expense breakdown by Family Members (Hidayat vs Deasy)
    double expenseHidayat = 0;
    double expenseDeasy = 0;
    for (var t in state.monthlyTransactions) {
      if (t.type == TransactionType.expense) {
        if (t.actor == Actor.hidayatullah) {
          expenseHidayat += t.amount;
        } else {
          expenseDeasy += t.amount;
        }
      }
    }

    return LiquidGlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      borderGradient: LinearGradient(
        colors: [
          healthColor.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.04),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: healthColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kesehatan Finansial Keluarga',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              LiquidGlassBadge(
                label: '$score/100',
                color: healthColor,
                isGlowing: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Health Score Progress Indicator
          LiquidProgressBar(
            value: score / 100,
            color: healthColor,
            height: 6,
          ),
          const SizedBox(height: 10),

          Text(
            healthStatus,
            style: TextStyle(
              color: healthColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          // Smart Insight Pills
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _buildInsightRow(
                  icon: Icons.savings_outlined,
                  title: 'Rasio Tabungan Bulan Ini',
                  value: '${(savingsRate * 100).toStringAsFixed(0)}%',
                  valueColor: savingsRate >= 0.2
                      ? LiquidGlassTheme.surplusEmerald
                      : Colors.white70,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _buildInsightRow(
                  icon: Icons.people_outline_rounded,
                  title: 'Pengeluaran Hidayatullah',
                  value: format.format(expenseHidayat),
                  valueColor: LiquidGlassTheme.actorHidayat,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _buildInsightRow(
                  icon: Icons.favorite_border_rounded,
                  title: 'Pengeluaran Deasy Amalia',
                  value: format.format(expenseDeasy),
                  valueColor: LiquidGlassTheme.actorDeasy,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(
      BuildContext context, FinanceLoaded state, NumberFormat format) {
    final totalGoals = state.goals.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Financial Goals Keluarga',
          icon: Icons.flag_rounded,
          iconColor: LiquidGlassTheme.primaryVioletLight,
          trailing: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FinanceBloc>(),
                    child: ManageGoalsPage(
                      bloc: context.read<FinanceBloc>(),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: LiquidGlassTheme.primaryViolet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LiquidGlassTheme.primaryViolet.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Kelola Goals',
                    style: TextStyle(
                      color: LiquidGlassTheme.primaryVioletLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: LiquidGlassTheme.primaryVioletLight,
                    size: 9,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (state.goals.isEmpty)
          LiquidGlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(22),
            child: Center(
              child: Text(
                'Belum ada target keuangan. Yuk mulai buat goal!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...state.goals.map((goal) {
            final double percent = goal.allocationPercentage > 0
                ? goal.allocationPercentage
                : (totalGoals > 0 ? 100.0 / totalGoals : 0.0);

            double assignedAmount = state.currentBalance * (percent / 100.0);
            if (assignedAmount > goal.targetAmount) {
              assignedAmount = goal.targetAmount;
            }
            double progress =
                (assignedAmount / goal.targetAmount).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: LiquidGlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient:
                                      LiquidGlassTheme.primaryLiquidGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Alokasi ${percent.toStringAsFixed(0)}% dari saldo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: LiquidGlassTheme
                                            .primaryVioletLight
                                            .withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        LiquidGlassBadge(
                          label: '${(progress * 100).toStringAsFixed(1)}%',
                          color: LiquidGlassTheme.primaryVioletLight,
                          isGlowing: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LiquidProgressBar(
                      value: progress,
                      height: 8,
                      gradient: LiquidGlassTheme.primaryLiquidGradient,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Alokasi: ${format.format(assignedAmount)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Target: ${format.format(goal.targetAmount)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  /// FEATURE: Summary Pengeluaran Mingguan Tiap Bulan
  Widget _buildWeeklyExpenseSummary(FinanceLoaded state, NumberFormat format) {
    final expenses = state.monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final Map<int, List<TransactionEntity>> weekMap = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };

    for (var tx in expenses) {
      final day = tx.date.day;
      if (day <= 7) {
        weekMap[1]!.add(tx);
      } else if (day <= 14) {
        weekMap[2]!.add(tx);
      } else if (day <= 21) {
        weekMap[3]!.add(tx);
      } else if (day <= 28) {
        weekMap[4]!.add(tx);
      } else {
        weekMap[5]!.add(tx);
      }
    }

    final int year = state.selectedMonth.year;
    final int month = state.selectedMonth.month;
    // Real-world exact number of days for this specific month & year (including leap years)
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final String monthAbbr =
        DateFormat('MMM', 'id_ID').format(state.selectedMonth);
    final int activeWeeks = daysInMonth > 28 ? 5 : 4;

    int maxWeek = 1;
    double maxAmount = 0;
    for (int w = 1; w <= activeWeeks; w++) {
      final total = weekMap[w]!.fold(0.0, (sum, tx) => sum + tx.amount);
      if (total > maxAmount) {
        maxAmount = total;
        maxWeek = w;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Summary Pengeluaran Mingguan',
          icon: Icons.calendar_view_week_rounded,
          iconColor: LiquidGlassTheme.amberWarning,
          trailing: Text(
            '${DateFormat('MMMM yyyy', 'id_ID').format(state.selectedMonth)} ($daysInMonth Hari)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        LiquidGlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(activeWeeks, (index) {
              final weekNum = index + 1;
              final list = weekMap[weekNum]!;
              final weekTotal = list.fold(0.0, (sum, tx) => sum + tx.amount);
              final ratio = state.monthlyExpense > 0
                  ? (weekTotal / state.monthlyExpense).clamp(0.0, 1.0)
                  : 0.0;
              final isMax =
                  maxAmount > 0 && weekNum == maxWeek && weekTotal > 0;

              int startDay;
              int endDay;
              if (weekNum == 1) {
                startDay = 1;
                endDay = 7;
              } else if (weekNum == 2) {
                startDay = 8;
                endDay = 14;
              } else if (weekNum == 3) {
                startDay = 15;
                endDay = 21;
              } else if (weekNum == 4) {
                startDay = 22;
                endDay = 28;
              } else {
                startDay = 29;
                endDay = daysInMonth;
              }

              final startDate = DateTime(year, month, startDay);
              final endDate = DateTime(year, month, endDay);
              final String startDayName =
                  DateFormat('EEE', 'id_ID').format(startDate);
              final String endDayName =
                  DateFormat('EEE', 'id_ID').format(endDate);

              String dateRange;
              if (startDay == endDay) {
                dateRange = '$startDayName, $startDay $monthAbbr';
              } else {
                dateRange =
                    '$startDayName, $startDay - $endDayName, $endDay $monthAbbr';
              }

              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == activeWeeks - 1 ? 0.0 : 14.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FinanceBloc>(),
                          child: WeeklyExpenseDetailPage(
                            weekNum: weekNum,
                            startDate: startDate,
                            endDate: endDate,
                            selectedMonth: state.selectedMonth,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isMax
                                            ? LiquidGlassTheme.defisitRose
                                                .withValues(alpha: 0.2)
                                            : Colors.white
                                                .withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isMax
                                              ? LiquidGlassTheme.defisitRose
                                                  .withValues(alpha: 0.5)
                                              : Colors.white
                                                  .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Text(
                                        'Minggu $weekNum ($dateRange)',
                                        style: TextStyle(
                                          color: isMax
                                              ? LiquidGlassTheme
                                                  .defisitRoseLight
                                              : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (isMax) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: LiquidGlassTheme.defisitRose
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '🔥 Max',
                                        style: TextStyle(
                                          color:
                                              LiquidGlassTheme.defisitRoseLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    format.format(weekTotal),
                                    style: TextStyle(
                                      color: weekTotal > 0
                                          ? (isMax
                                              ? LiquidGlassTheme
                                                  .defisitRoseLight
                                              : Colors.white)
                                          : Colors.white.withValues(alpha: 0.4),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LiquidProgressBar(
                          value: ratio,
                          height: 6,
                          gradient: isMax
                              ? LiquidGlassTheme.defisitLiquidGradient
                              : const LinearGradient(
                                  colors: [
                                    LiquidGlassTheme.secondaryCyan,
                                    LiquidGlassTheme.primaryViolet,
                                  ],
                                ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${list.length} transaksi • Ketuk untuk rincian',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${(ratio * 100).toStringAsFixed(1)}% pengeluaran',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetPlansSection(
      BuildContext context, FinanceLoaded state, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Planning & Holiday Budget',
          icon: Icons.flight_takeoff_rounded,
          iconColor: LiquidGlassTheme.secondaryCyan,
          trailing: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FinanceBloc>(),
                    child: ManageBudgetPage(budgetPlans: state.budgetPlans),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: LiquidGlassTheme.secondaryCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LiquidGlassTheme.secondaryCyan.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Kelola Plan',
                    style: TextStyle(
                      color: LiquidGlassTheme.secondaryCyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: LiquidGlassTheme.secondaryCyan,
                    size: 9,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (state.budgetPlans.isEmpty)
          LiquidGlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(22),
            child: Center(
              child: Text(
                'Belum ada rencana budget / liburan.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...state.budgetPlans.map((plan) {
            double progress =
                (plan.spentAmount / plan.allocatedBudget).clamp(0.0, 1.0);
            bool isOver = plan.spentAmount > plan.allocatedBudget;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: LiquidGlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                borderColor: isOver
                    ? LiquidGlassTheme.defisitRose.withValues(alpha: 0.3)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: isOver
                                      ? LiquidGlassTheme.defisitLiquidGradient
                                      : LiquidGlassTheme.aquaLiquidGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isOver
                                      ? Icons.warning_amber_rounded
                                      : Icons.beach_access_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        LiquidGlassBadge(
                          label: isOver ? 'Over Budget' : plan.category,
                          color: isOver
                              ? LiquidGlassTheme.defisitRose
                              : LiquidGlassTheme.secondaryCyan,
                          isGlowing: isOver,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LiquidProgressBar(
                      value: progress,
                      height: 8,
                      gradient: isOver
                          ? LiquidGlassTheme.defisitLiquidGradient
                          : LiquidGlassTheme.aquaLiquidGradient,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Terpakai: ${format.format(plan.spentAmount)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOver
                                  ? LiquidGlassTheme.defisitRose
                                  : Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Budget: ${format.format(plan.allocatedBudget)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildModernChart(
      List<TransactionEntity> transactions, NumberFormat format) {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return const SizedBox();

    final Map<String, double> categoryMap = {};
    for (var e in expenses) {
      categoryMap[e.category] = (categoryMap[e.category] ?? 0) + e.amount;
    }

    final totalExpense = categoryMap.values.fold(0.0, (a, b) => a + b);

    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFF43F5E),
      const Color(0xFF38BDF8),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];

    int cIndex = 0;
    final sections = categoryMap.entries.map((e) {
      final color = colors[cIndex % colors.length];
      cIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        radius: 16,
        showTitle: false,
      );
    }).toList();

    return LiquidGlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 3,
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      color: LiquidGlassTheme.secondaryCyan,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: categoryMap.entries.take(4).map((e) {
                final idx = categoryMap.keys.toList().indexOf(e.key);
                final color = colors[idx % colors.length];
                final percentage =
                    totalExpense > 0 ? (e.value / totalExpense * 100) : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  /// FEATURE: Search & Filter Transaction Section
  Widget _buildTransactionSection(BuildContext context,
      List<TransactionEntity> transactions, NumberFormat format) {
    // Apply filters
    final filtered = transactions.where((t) {
      final matchesQuery = _searchQuery.isEmpty ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.note.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesActor =
          _selectedActorFilter == null || t.actor == _selectedActorFilter;

      final matchesType =
          _selectedTypeFilter == null || t.type == _selectedTypeFilter;

      return matchesQuery && matchesActor && matchesType;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Riwayat Transaksi',
          icon: Icons.receipt_long_rounded,
          iconColor: LiquidGlassTheme.primaryViolet,
          trailing: Text(
            '${filtered.length} Transaksi',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Search Input
        LiquidGlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              icon: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
              hintText: 'Cari transaksi / catatan...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              border: InputBorder.none,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.white54, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Actor Filters
              LiquidQuickChip(
                label: 'Semua Anggota',
                isSelected: _selectedActorFilter == null,
                onTap: () => setState(() => _selectedActorFilter = null),
              ),
              const SizedBox(width: 6),
              LiquidQuickChip(
                label: '👨 Hidayatullah',
                isSelected: _selectedActorFilter == Actor.hidayatullah,
                activeColor: LiquidGlassTheme.actorHidayat,
                onTap: () =>
                    setState(() => _selectedActorFilter = Actor.hidayatullah),
              ),
              const SizedBox(width: 6),
              LiquidQuickChip(
                label: '👩 Deasy',
                isSelected: _selectedActorFilter == Actor.deasy,
                activeColor: LiquidGlassTheme.actorDeasy,
                onTap: () => setState(() => _selectedActorFilter = Actor.deasy),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: Colors.white12),
              const SizedBox(width: 12),

              // Type Filters
              LiquidQuickChip(
                label: '⬇️ Masuk',
                isSelected: _selectedTypeFilter == TransactionType.income,
                activeColor: LiquidGlassTheme.surplusEmerald,
                onTap: () => setState(() => _selectedTypeFilter =
                    _selectedTypeFilter == TransactionType.income
                        ? null
                        : TransactionType.income),
              ),
              const SizedBox(width: 6),
              LiquidQuickChip(
                label: '⬆️ Keluar',
                isSelected: _selectedTypeFilter == TransactionType.expense,
                activeColor: LiquidGlassTheme.defisitRose,
                onTap: () => setState(() => _selectedTypeFilter =
                    _selectedTypeFilter == TransactionType.expense
                        ? null
                        : TransactionType.expense),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Filtered Transaction List
        if (filtered.isEmpty)
          LiquidGlassContainer(
            borderRadius: 22,
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 36,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tidak ada transaksi yang cocok',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          ...filtered.map((t) {
            final isIncome = t.type == TransactionType.income;
            final color = isIncome
                ? LiquidGlassTheme.surplusEmerald
                : LiquidGlassTheme.defisitRose;
            final gradient = isIncome
                ? LiquidGlassTheme.surplusLiquidGradient
                : LiquidGlassTheme.defisitLiquidGradient;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: LiquidGlassContainer(
                borderRadius: 18,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<FinanceBloc>(),
                        child: TransactionDetailPage(transaction: t),
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      t.receiptImagePath != null
                          ? Icons.receipt_rounded
                          : (isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    t.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(
                      children: [
                        FamilyActorBadge(
                          fullName: t.actor.fullName,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${t.actor.shortName} • ${DateFormat('dd MMM').format(t.date)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${isIncome ? '+' : '-'}${format.format(t.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActionDock(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is! FinanceLoaded) return const SizedBox();

        final now = DateTime.now();
        final isCurrentMonth = state.selectedMonth.year == now.year &&
            state.selectedMonth.month == now.month;

        // JIKA BUKAN BULAN INI (BULAN LALU ATAU BULAN DEPAN): KUNCI INPUT
        if (!isCurrentMonth) {
          final isPast =
              state.selectedMonth.isBefore(DateTime(now.year, now.month));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: LiquidGlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderColor:
                  LiquidGlassTheme.amberWarning.withValues(alpha: 0.35),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          LiquidGlassTheme.amberWarning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: LiquidGlassTheme.amberWarning,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPast
                              ? 'Arsip Bulan Lalu (Terkunci)'
                              : 'Bulan Depan (Terkunci)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Catat transaksi hanya bisa di bulan berjalan (${DateFormat('MMM yyyy', 'id_ID').format(now)}).',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  LiquidGlassButton(
                    onPressed: () {
                      context
                          .read<FinanceBloc>()
                          .add(ChangeMonthEvent(DateTime(now.year, now.month)));
                    },
                    label: 'Bulan Ini',
                    icon: Icons.restore_rounded,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: 16,
                    gradient: LiquidGlassTheme.primaryLiquidGradient,
                    glowColor: LiquidGlassTheme.primaryViolet,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Inject Saldo Glass Button
              LiquidGlassIconButton(
                size: 52,
                icon: Icons.account_balance_wallet_rounded,
                tooltip: 'Inject Saldo Awal',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<FinanceBloc>(),
                        child: const AddTransactionPage(isInitialBalance: true),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              // Main Catat Transaksi Button
              Expanded(
                child: LiquidGlassButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FinanceBloc>(),
                          child: const AddTransactionPage(),
                        ),
                      ),
                    );
                  },
                  label: 'Catat Transaksi',
                  icon: Icons.add_rounded,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  gradient: LiquidGlassTheme.primaryLiquidGradient,
                  glowColor: LiquidGlassTheme.primaryViolet,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
