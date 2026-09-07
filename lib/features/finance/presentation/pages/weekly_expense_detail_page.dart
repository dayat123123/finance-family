import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_detail_page.dart';

class WeeklyExpenseDetailPage extends StatefulWidget {
  final int weekNum;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedMonth;

  const WeeklyExpenseDetailPage({
    super.key,
    required this.weekNum,
    required this.startDate,
    required this.endDate,
    required this.selectedMonth,
  });

  @override
  State<WeeklyExpenseDetailPage> createState() =>
      _WeeklyExpenseDetailPageState();
}

class _WeeklyExpenseDetailPageState extends State<WeeklyExpenseDetailPage> {
  String _selectedActorFilter = 'Semua';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final fullDateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final shortDateFormat = DateFormat('d MMM yyyy', 'id_ID');

    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              if (state is! FinanceLoaded) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: LiquidGlassTheme.primaryViolet,
                  ),
                );
              }

              // Filter transactions in this exact week and month
              final weekExpenses = state.monthlyTransactions.where((t) {
                if (t.type != TransactionType.expense) return false;
                final day = t.date.day;
                return day >= widget.startDate.day && day <= widget.endDate.day;
              }).toList();

              // Sort newest first
              weekExpenses.sort((a, b) => b.date.compareTo(a.date));

              final double weekTotal =
                  weekExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

              // Contribution to monthly expense
              final double monthlyExpense = state.monthlyExpense;
              final double monthlyRatio = monthlyExpense > 0
                  ? (weekTotal / monthlyExpense).clamp(0.0, 1.0)
                  : 0.0;

              // Split by actor
              final double hidayatTotal = weekExpenses
                  .where((t) => t.actor == Actor.hidayatullah)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              final double deasyTotal = weekExpenses
                  .where((t) => t.actor == Actor.deasy)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              // Group by category
              final Map<String, double> categoryTotals = {};
              for (var tx in weekExpenses) {
                categoryTotals[tx.category] =
                    (categoryTotals[tx.category] ?? 0.0) + tx.amount;
              }
              final sortedCategories = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // Filtered list for UI
              final displayedTransactions = weekExpenses.where((t) {
                final matchActor = _selectedActorFilter == 'Semua' ||
                    (_selectedActorFilter == 'Hidayatullah' &&
                        t.actor == Actor.hidayatullah) ||
                    (_selectedActorFilter == 'Deasy' && t.actor == Actor.deasy);
                final matchQuery = _searchQuery.isEmpty ||
                    t.category
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    t.note.toLowerCase().contains(_searchQuery.toLowerCase());
                return matchActor && matchQuery;
              }).toList();

              return Column(
                children: [
                  // Top Navigation Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            LiquidGlassBackButton(
                              size: 38,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Minggu ${widget.weekNum}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${shortDateFormat.format(widget.startDate)} - ${shortDateFormat.format(widget.endDate)}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.defisitRose
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LiquidGlassTheme.defisitRose
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '${(monthlyRatio * 100).toStringAsFixed(0)}% Pengeluaran',
                            style: const TextStyle(
                              color: LiquidGlassTheme.defisitRoseLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Scroll
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      children: [
                        // Hero Total Card
                        LiquidGlassContainer(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(22),
                          borderColor: LiquidGlassTheme.defisitRose
                              .withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: LiquidGlassTheme.defisitRose
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward_rounded,
                                          color:
                                              LiquidGlassTheme.defisitRoseLight,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Total Pengeluaran Minggu Ini',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${weekExpenses.length} Transaksi',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  format.format(weekTotal),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${fullDateFormat.format(widget.startDate)}  s/d  ${fullDateFormat.format(widget.endDate)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Actor Split Stats
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildActorStat(
                                        name: 'Hidayatullah',
                                        amount: format.format(hidayatTotal),
                                        color: LiquidGlassTheme.actorHidayat,
                                        icon: Icons.person_rounded,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 32,
                                      color: Colors.white10,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                    Expanded(
                                      child: _buildActorStat(
                                        name: 'Deasy Amalia',
                                        amount: format.format(deasyTotal),
                                        color: LiquidGlassTheme.actorDeasy,
                                        icon: Icons.favorite_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Category Breakdown Section
                        if (sortedCategories.isNotEmpty) ...[
                          const Row(
                            children: [
                              Icon(
                                Icons.pie_chart_outline_rounded,
                                color: LiquidGlassTheme.secondaryCyan,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Kategori Pengeluaran Minggu Ini',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LiquidGlassContainer(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: sortedCategories.map((entry) {
                                final catRatio = weekTotal > 0
                                    ? (entry.value / weekTotal).clamp(0.0, 1.0)
                                    : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _buildCategoryIcon(entry.key),
                                              const SizedBox(width: 8),
                                              Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            format.format(entry.value),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LiquidProgressBar(
                                        value: catRatio,
                                        height: 5,
                                        gradient: LiquidGlassTheme
                                            .primaryLiquidGradient,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],

                        // Filter & Search Row
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              color: LiquidGlassTheme.primaryVioletLight,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Daftar Transaksi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${displayedTransactions.length} item',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Search Bar
                        LiquidGlassContainer(
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              hintText: 'Cari catatan atau kategori...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Actor Filter Chips
                        Row(
                          children: [
                            _buildFilterChip('Semua'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Hidayatullah'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Deasy'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Transactions List
                        if (displayedTransactions.isEmpty)
                          LiquidGlassContainer(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_outlined,
                                    size: 36,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada transaksi pengeluaran di minggu ini',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...displayedTransactions.map((tx) {
                            final isHidayat = tx.actor == Actor.hidayatullah;
                            final actorColor = isHidayat
                                ? LiquidGlassTheme.actorHidayat
                                : LiquidGlassTheme.actorDeasy;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: LiquidGlassContainer(
                                borderRadius: 18,
                                padding: const EdgeInsets.all(14),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<FinanceBloc>(),
                                        child: TransactionDetailPage(
                                            transaction: tx),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: LiquidGlassTheme.defisitRose
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _buildCategoryIcon(tx.category),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tx.category,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (tx.receiptImagePath != null)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 6),
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: const Icon(
                                                    Icons.camera_alt_rounded,
                                                    size: 11,
                                                    color: LiquidGlassTheme
                                                        .secondaryCyan,
                                                  ),
                                                ),
                                              LiquidGlassBadge(
                                                label: isHidayat
                                                    ? '👨 Hidayatullah'
                                                    : '👩 Deasy',
                                                color: actorColor,
                                                fontSize: 9,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tx.note.isNotEmpty
                                                      ? tx.note
                                                      : DateFormat(
                                                              'EEE, d MMM - HH:mm',
                                                              'id_ID')
                                                          .format(tx.date),
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.55),
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '-${format.format(tx.amount)}',
                                                style: const TextStyle(
                                                  color: LiquidGlassTheme
                                                      .defisitRoseLight,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
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
                          }),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActorStat({
    required String name,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedActorFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedActorFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? LiquidGlassTheme.primaryViolet.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? LiquidGlassTheme.primaryVioletLight.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData iconData = Icons.receipt_rounded;
    final catLower = category.toLowerCase();
    if (catLower.contains('makan') || catLower.contains('kuliner')) {
      iconData = Icons.restaurant_rounded;
    } else if (catLower.contains('belanja') || catLower.contains('shopping')) {
      iconData = Icons.shopping_bag_rounded;
    } else if (catLower.contains('transport') || catLower.contains('bensin')) {
      iconData = Icons.directions_car_rounded;
    } else if (catLower.contains('tagihan') || catLower.contains('listrik')) {
      iconData = Icons.receipt_long_rounded;
    } else if (catLower.contains('hiburan') || catLower.contains('nonton')) {
      iconData = Icons.movie_rounded;
    } else if (catLower.contains('kesehatan') || catLower.contains('obat')) {
      iconData = Icons.medical_services_rounded;
    } else if (catLower.contains('pendidikan') ||
        catLower.contains('sekolah')) {
      iconData = Icons.school_rounded;
    }

    return Icon(iconData, size: 14, color: LiquidGlassTheme.defisitRoseLight);
  }
}
