import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/transaction.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  void _showStrictDeleteConfirmation(BuildContext context) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return LiquidGlassDialog(
              icon: Icons.warning_amber_rounded,
              iconColor: LiquidGlassTheme.defisitRose,
              iconGradient: LiquidGlassTheme.defisitLiquidGradient,
              title: 'Hapus Transaksi?',
              subtitle:
                  'Tindakan ini bersifat permanen & mempengaruhi total saldo',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Untuk memastikan keamanan, silakan ketik kata 'HAPUS' di bawah ini:",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    borderColor:
                        LiquidGlassTheme.defisitRose.withValues(alpha: 0.4),
                    child: TextField(
                      controller: confirmController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ketik HAPUS',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          letterSpacing: 1.5,
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
                    if (confirmController.text.trim().toUpperCase() ==
                        'HAPUS') {
                      context
                          .read<FinanceBloc>()
                          .add(DeleteTransactionEvent(transaction.id));
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Transaksi berhasil dihapus secara permanen'),
                          backgroundColor: LiquidGlassTheme.surfaceDark,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Konfirmasi salah! Ketik "HAPUS" dengan benar'),
                          backgroundColor: LiquidGlassTheme.defisitRose,
                        ),
                      );
                    }
                  },
                  label: 'HAPUS',
                  icon: Icons.delete_forever_rounded,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  gradient: LiquidGlassTheme.defisitLiquidGradient,
                  glowColor: LiquidGlassTheme.defisitRose,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: LiquidGlassBackButton(
                icon: Icons.close_rounded,
                size: 36,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isIncome = transaction.type == TransactionType.income ||
        transaction.type == TransactionType.initialBalance;
    final color = isIncome
        ? LiquidGlassTheme.surplusEmerald
        : LiquidGlassTheme.defisitRose;
    final gradient = isIncome
        ? LiquidGlassTheme.surplusLiquidGradient
        : LiquidGlassTheme.defisitLiquidGradient;

    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar with Proportionate Back Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LiquidGlassBackButton(
                      size: 38,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    LiquidGlassIconButton(
                      size: 38,
                      icon: Icons.delete_outline_rounded,
                      iconColor: LiquidGlassTheme.defisitRose,
                      backgroundColor:
                          LiquidGlassTheme.defisitRose.withValues(alpha: 0.12),
                      borderColor:
                          LiquidGlassTheme.defisitRose.withValues(alpha: 0.3),
                      tooltip: 'Hapus Transaksi',
                      onPressed: () => _showStrictDeleteConfirmation(context),
                    ),
                  ],
                ),
              ),

              // Detail Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),

                      // Liquid Type Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          transaction.type == TransactionType.initialBalance
                              ? Icons.account_balance_wallet_rounded
                              : (isIncome
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount Display
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${isIncome ? '+' : '-'}${format.format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category Badge
                      LiquidGlassBadge(
                        label: transaction.category,
                        color: color,
                        isGlowing: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                      ),
                      const SizedBox(height: 28),

                      // Metadata Container
                      LiquidGlassContainer(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Tanggal',
                              DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                                  .format(transaction.date),
                              icon: Icons.calendar_today_rounded,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                color: Colors.white10,
                                height: 1,
                              ),
                            ),
                            _buildDetailRow(
                              'Tipe Transaksi',
                              transaction.type == TransactionType.initialBalance
                                  ? 'Inject Saldo Awal'
                                  : (isIncome ? 'Pemasukan' : 'Pengeluaran'),
                              icon: Icons.swap_horiz_rounded,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                color: Colors.white10,
                                height: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 15,
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Penanggung Jawab',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FamilyActorBadge(
                                        fullName: transaction.actor.fullName,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          transaction.actor.fullName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (transaction.note.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: Colors.white10,
                                  height: 1,
                                ),
                              ),
                              _buildDetailRow(
                                'Catatan',
                                transaction.note,
                                icon: Icons.notes_rounded,
                              ),
                            ]
                          ],
                        ),
                      ),

                      // Receipt Section
                      if (transaction.receiptImagePath != null) ...[
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lampiran Struk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showImagePreview(
                              context, transaction.receiptImagePath!),
                          child: LiquidGlassContainer(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(transaction.receiptImagePath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.zoom_in_rounded,
                                          color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Text(
                                        'Perbesar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 28),
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

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
