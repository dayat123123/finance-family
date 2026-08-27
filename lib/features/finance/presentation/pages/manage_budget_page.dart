import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keuangan_keluarga_ultimate/core/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/budget_plan.dart';

class ManageBudgetPage extends StatelessWidget {
  final List<BudgetPlanEntity> budgetPlans;
  const ManageBudgetPage({super.key, required this.budgetPlans});

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header with Proportionate Back Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        const Text(
                          'Planning & Holiday',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    LiquidGlassIconButton(
                      size: 38,
                      icon: Icons.add_rounded,
                      gradient: LiquidGlassTheme.aquaLiquidGradient,
                      tooltip: 'Tambah Plan',
                      onPressed: () => _showBudgetDialog(context),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    final List<BudgetPlanEntity> plans = state is FinanceLoaded
                        ? state.budgetPlans
                        : budgetPlans;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Daftar Rencana Pengeluaran & Liburan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (plans.isEmpty)
                          LiquidGlassContainer(
                            borderRadius: 24,
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: LiquidGlassTheme.secondaryCyan,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada rencana budget / liburan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rencanakan anggaran liburan atau event keluarga dengan rapi!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...plans.map((plan) {
                            final isOver =
                                plan.spentAmount > plan.allocatedBudget;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: LiquidGlassContainer(
                                borderRadius: 20,
                                padding: const EdgeInsets.all(14),
                                borderColor: isOver
                                    ? LiquidGlassTheme.defisitRose
                                        .withValues(alpha: 0.3)
                                    : null,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: isOver
                                            ? LiquidGlassTheme
                                                .defisitLiquidGradient
                                            : LiquidGlassTheme
                                                .aquaLiquidGradient,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        isOver
                                            ? Icons.warning_amber_rounded
                                            : Icons.flight_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Budget: ${format.format(plan.allocatedBudget)} | Terpakai: ${format.format(plan.spentAmount)}',
                                              style: TextStyle(
                                                color: isOver
                                                    ? LiquidGlassTheme
                                                        .defisitRose
                                                    : Colors.white
                                                        .withValues(alpha: 0.6),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    LiquidGlassIconButton(
                                      size: 34,
                                      icon: Icons.edit_rounded,
                                      iconColor: Colors.white70,
                                      onPressed: () => _showBudgetDialog(
                                          context,
                                          plan: plan),
                                    ),
                                    const SizedBox(width: 6),
                                    LiquidGlassIconButton(
                                      size: 34,
                                      icon: Icons.delete_outline_rounded,
                                      iconColor: LiquidGlassTheme.defisitRose,
                                      onPressed: () {
                                        context.read<FinanceBloc>().add(
                                            DeleteBudgetPlanEvent(plan.id));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 20),
                        LiquidGlassButton(
                          onPressed: () => _showBudgetDialog(context),
                          label: 'Tambah Plan / Holiday Budget',
                          icon: Icons.add_rounded,
                          isFullWidth: true,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: 26,
                          gradient: LiquidGlassTheme.aquaLiquidGradient,
                          glowColor: LiquidGlassTheme.secondaryCyan,
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, {BudgetPlanEntity? plan}) {
    final titleController = TextEditingController(text: plan?.title ?? '');
    final numFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final budgetController = TextEditingController(
      text: plan != null ? numFormat.format(plan.allocatedBudget).trim() : '',
    );
    final spentController = TextEditingController(
      text: plan != null ? numFormat.format(plan.spentAmount).trim() : '',
    );

    final suggestions = [
      {'name': '🏖️ Liburan Bali', 'budget': '15000000'},
      {'name': '✈️ Wisata Jepang', 'budget': '40000000'},
      {'name': '🚗 Mudik Lebaran', 'budget': '10000000'},
      {'name': '🍽️ Wisata Kuliner', 'budget': '3000000'},
      {'name': '🛍️ Belanja Fashion', 'budget': '5000000'},
      {'name': '🛠️ Renovasi Rumah', 'budget': '20000000'},
    ];

    final quickAmounts = [
      {'label': '+1 Jt', 'val': 1000000},
      {'label': '+3 Jt', 'val': 3000000},
      {'label': '+5 Jt', 'val': 5000000},
      {'label': '+10 Jt', 'val': 10000000},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return LiquidGlassDialog(
              icon: Icons.beach_access_rounded,
              iconColor: LiquidGlassTheme.secondaryCyan,
              iconGradient: LiquidGlassTheme.aquaLiquidGradient,
              title: plan == null ? 'Rencana Budget Baru' : 'Edit Budget Plan',
              subtitle: plan == null
                  ? 'Atur alokasi anggaran liburan atau event keluarga'
                  : 'Perbarui rencana alokasi dan realisasi',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PILIHAN CEPAT (REKOMENDASI)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: suggestions.map((s) {
                      final isSelected = titleController.text == s['name'];
                      return LiquidQuickChip(
                        label: s['name']!,
                        isSelected: isSelected,
                        activeColor: LiquidGlassTheme.secondaryCyan,
                        onTap: () {
                          setStateDialog(() {
                            titleController.text = s['name']!;
                            if (budgetController.text.isEmpty) {
                              final numVal = double.tryParse(s['budget']!) ?? 0;
                              budgetController.text =
                                  numFormat.format(numVal).trim();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Title Input
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: titleController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: LiquidGlassTheme.secondaryCyan,
                          size: 18,
                        ),
                        labelText: 'Nama Event / Liburan',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Allocated Budget
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: LiquidGlassTheme.secondaryCyan,
                          size: 18,
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: LiquidGlassTheme.secondaryCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        labelText: 'Alokasi Anggaran (Budget)',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Amount Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: quickAmounts.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: LiquidQuickChip(
                            label: q['label'] as String,
                            activeColor: LiquidGlassTheme.secondaryCyan,
                            onTap: () {
                              final curStr = budgetController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              final cur = double.tryParse(curStr) ?? 0;
                              final next = cur + (q['val'] as int);
                              setStateDialog(() {
                                budgetController.text =
                                    numFormat.format(next).trim();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Spent Amount Field
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: spentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.receipt_long_rounded,
                          color: LiquidGlassTheme.defisitRose,
                          size: 18,
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: LiquidGlassTheme.defisitRose,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        labelText: 'Sudah Terpakai (Opsional)',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                LiquidGlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: () => Navigator.pop(ctx),
                  child: Center(
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                LiquidGlassButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final budget = double.tryParse(budgetController.text
                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0;
                    final spent = double.tryParse(spentController.text
                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0;

                    if (title.isNotEmpty && budget > 0) {
                      if (plan == null) {
                        final newPlan = BudgetPlanEntity(
                          id: const Uuid().v4(),
                          title: title,
                          allocatedBudget: budget,
                          spentAmount: spent,
                          category: 'Hiburan',
                        );
                        context
                            .read<FinanceBloc>()
                            .add(AddBudgetPlanEvent(newPlan));
                      } else {
                        final updated = BudgetPlanEntity(
                          id: plan.id,
                          title: title,
                          allocatedBudget: budget,
                          spentAmount: spent,
                          category: plan.category,
                        );
                        context
                            .read<FinanceBloc>()
                            .add(EditBudgetPlanEvent(updated));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  label: 'Simpan',
                  icon: Icons.check_circle_rounded,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  gradient: LiquidGlassTheme.aquaLiquidGradient,
                  glowColor: LiquidGlassTheme.secondaryCyan,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
