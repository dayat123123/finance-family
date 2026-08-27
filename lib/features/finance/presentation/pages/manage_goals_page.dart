import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keuangan_keluarga_ultimate/core/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/goal.dart';

class ManageGoalsPage extends StatelessWidget {
  final FinanceBloc bloc;
  const ManageGoalsPage({super.key, required this.bloc});

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
                          'Kelola Goals',
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
                      gradient: LiquidGlassTheme.primaryLiquidGradient,
                      tooltip: 'Tambah Target',
                      onPressed: () => _showGoalDialog(context),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    final List<GoalEntity> goals =
                        state is FinanceLoaded ? state.goals : [];

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Daftar Target Tabungan Bersama',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (goals.isEmpty)
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
                                    Icons.emoji_events_outlined,
                                    color: LiquidGlassTheme.primaryVioletLight,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada target yang dibuat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mulai rencanakan impian bersama keluarga sekarang!',
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
                          ...goals.map(
                            (goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: LiquidGlassContainer(
                                borderRadius: 20,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LiquidGlassTheme
                                            .primaryLiquidGradient,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.flag_rounded,
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
                                            goal.title,
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
                                              'Target: ${format.format(goal.targetAmount)}',
                                              style: TextStyle(
                                                color: Colors.white
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
                                      onPressed: () =>
                                          _showGoalDialog(context, goal: goal),
                                    ),
                                    const SizedBox(width: 6),
                                    LiquidGlassIconButton(
                                      size: 34,
                                      icon: Icons.delete_outline_rounded,
                                      iconColor: LiquidGlassTheme.defisitRose,
                                      onPressed: () {
                                        context
                                            .read<FinanceBloc>()
                                            .add(DeleteGoalEvent(goal.id));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        LiquidGlassButton(
                          onPressed: () => _showGoalDialog(context),
                          label: 'Tambah Target Baru',
                          icon: Icons.add_rounded,
                          isFullWidth: true,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: 26,
                          gradient: LiquidGlassTheme.primaryLiquidGradient,
                          glowColor: LiquidGlassTheme.primaryViolet,
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

  void _showGoalDialog(BuildContext context, {GoalEntity? goal}) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final numFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final amountController = TextEditingController(
      text: goal != null ? numFormat.format(goal.targetAmount).trim() : '',
    );

    final suggestions = [
      {'name': '🏠 Beli Rumah', 'target': '500000000'},
      {'name': '🚗 Mobil Keluarga', 'target': '200000000'},
      {'name': '🏖️ Liburan Impian', 'target': '25000000'},
      {'name': '🎓 Pendidikan Anak', 'target': '100000000'},
      {'name': '🛡️ Dana Darurat', 'target': '50000000'},
      {'name': '💍 Tabungan Nikah', 'target': '60000000'},
    ];

    final quickAmounts = [
      {'label': '+10 Jt', 'val': 10000000},
      {'label': '+25 Jt', 'val': 25000000},
      {'label': '+50 Jt', 'val': 50000000},
      {'label': '+100 Jt', 'val': 100000000},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return LiquidGlassDialog(
              icon: Icons.emoji_events_rounded,
              iconColor: LiquidGlassTheme.primaryVioletLight,
              iconGradient: LiquidGlassTheme.primaryLiquidGradient,
              title:
                  goal == null ? 'Target Finansial Baru' : 'Edit Target Impian',
              subtitle: goal == null
                  ? 'Tentukan target tabungan masa depan keluarga'
                  : 'Perbarui nominal atau nama impian',
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
                        onTap: () {
                          setStateDialog(() {
                            titleController.text = s['name']!;
                            if (amountController.text.isEmpty) {
                              final numVal = double.tryParse(s['target']!) ?? 0;
                              amountController.text =
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
                          Icons.flag_rounded,
                          color: LiquidGlassTheme.primaryVioletLight,
                          size: 18,
                        ),
                        labelText: 'Nama Target Finansial',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Target Amount
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.payments_rounded,
                          color: LiquidGlassTheme.surplusEmerald,
                          size: 18,
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: LiquidGlassTheme.surplusEmerald,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        labelText: 'Nominal Target',
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
                            activeColor: LiquidGlassTheme.surplusEmerald,
                            onTap: () {
                              final curStr = amountController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              final cur = double.tryParse(curStr) ?? 0;
                              final next = cur + (q['val'] as int);
                              setStateDialog(() {
                                amountController.text =
                                    numFormat.format(next).trim();
                              });
                            },
                          ),
                        );
                      }).toList(),
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
                    final amountStr =
                        amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(amountStr) ?? 0;

                    if (title.isNotEmpty && amount > 0) {
                      if (goal == null) {
                        final newGoal = GoalEntity(
                          id: const Uuid().v4(),
                          title: title,
                          targetAmount: amount,
                        );
                        context.read<FinanceBloc>().add(AddGoalEvent(newGoal));
                      } else {
                        final updated = GoalEntity(
                          id: goal.id,
                          title: title,
                          targetAmount: amount,
                        );
                        context.read<FinanceBloc>().add(EditGoalEvent(updated));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  label: 'Simpan',
                  icon: Icons.check_circle_rounded,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  gradient: LiquidGlassTheme.primaryLiquidGradient,
                  glowColor: LiquidGlassTheme.primaryViolet,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
