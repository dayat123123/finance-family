import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keuangan_keluarga_ultimate/core/utils/currency_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../../../../core/theme/liquid_glass_theme.dart';
import '../../../../core/widgets/liquid_glass_components.dart';
import '../bloc/finance_bloc.dart';
import '../../domain/entities/transaction.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isInitialBalance;
  const AddTransactionPage({super.key, this.isInitialBalance = false});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  Actor _selectedActor = Actor.hidayatullah;
  String? _selectedCategory;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.isInitialBalance) {
      _selectedType = TransactionType.initialBalance;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage =
          await File(pickedFile.path).copy('${directory.path}/$fileName');

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  void _showAddCategoryDialog(BuildContext context, FinanceLoaded state) {
    final catController = TextEditingController();

    final categorySuggestions = _selectedType == TransactionType.income
        ? [
            '💼 Gaji Bulanan',
            '🎁 Bonus & THR',
            '📈 Investasi & Dividen',
            '🤝 Bisnis Sampingan',
            '💸 Cashback / Hadiah',
          ]
        : [
            '🛒 Belanja Dapur',
            '⚡ Listrik & Air',
            '🍔 Makan & Kuliner',
            '🚗 Bensin & Tol',
            '💊 Obat & Medis',
            '📚 Sekolah Anak',
            '🌐 Internet & Pulsa',
            '🎁 Hadiah & Sedekah',
          ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return LiquidGlassDialog(
              icon: Icons.category_rounded,
              iconColor: _selectedType == TransactionType.income
                  ? LiquidGlassTheme.surplusEmerald
                  : LiquidGlassTheme.primaryVioletLight,
              iconGradient: _selectedType == TransactionType.income
                  ? LiquidGlassTheme.surplusLiquidGradient
                  : LiquidGlassTheme.primaryLiquidGradient,
              title:
                  'Kategori ${_selectedType == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'}',
              subtitle:
                  'Tambah opsi kategori baru untuk mempermudah pencatatan',
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
                    children: categorySuggestions.map((cat) {
                      final isSelected = catController.text == cat;
                      return LiquidQuickChip(
                        label: cat,
                        isSelected: isSelected,
                        activeColor: _selectedType == TransactionType.income
                            ? LiquidGlassTheme.surplusEmerald
                            : LiquidGlassTheme.primaryVioletLight,
                        onTap: () {
                          setStateDialog(() {
                            catController.text = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  LiquidGlassContainer(
                    borderRadius: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: TextField(
                      controller: catController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          color: LiquidGlassTheme.primaryVioletLight,
                          size: 18,
                        ),
                        labelText: 'Nama Kategori Baru',
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
                    final newCat = catController.text.trim();
                    if (newCat.isNotEmpty) {
                      context
                          .read<FinanceBloc>()
                          .add(AddCategoryEvent(_selectedType, newCat));
                      setState(() {
                        _selectedCategory = newCat;
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  label: 'Tambah',
                  icon: Icons.add_rounded,
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  gradient: _selectedType == TransactionType.income
                      ? LiquidGlassTheme.surplusLiquidGradient
                      : LiquidGlassTheme.primaryLiquidGradient,
                  glowColor: _selectedType == TransactionType.income
                      ? LiquidGlassTheme.surplusEmerald
                      : LiquidGlassTheme.primaryViolet,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is! FinanceLoaded) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(
                  color: LiquidGlassTheme.primaryViolet,
                ),
              ),
            );
          }

          List<String> currentCategories = widget.isInitialBalance
              ? ['Saldo Rekening Awal']
              : (_selectedType == TransactionType.income
                  ? state.incomeCategories
                  : state.expenseCategories);

          if (_selectedCategory == null ||
              !currentCategories.contains(_selectedCategory)) {
            _selectedCategory = currentCategories.first;
          }

          final isIncome = _selectedType == TransactionType.income;
          final activeThemeColor = widget.isInitialBalance
              ? LiquidGlassTheme.secondaryCyan
              : (isIncome
                  ? LiquidGlassTheme.surplusEmerald
                  : LiquidGlassTheme.defisitRose);

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                widget.isInitialBalance
                    ? 'Inject Saldo Awal'
                    : 'Input Transaksi',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              leading: Padding(
                padding:
                    const EdgeInsets.only(left: 14.0, top: 8.0, bottom: 8.0),
                child: LiquidGlassBackButton(
                  icon: Icons.close_rounded,
                  size: 38,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Switcher
                    if (!widget.isInitialBalance)
                      Center(
                        child: LiquidGlassContainer(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTypeTab(
                                type: TransactionType.income,
                                label: 'Pemasukan',
                                icon: Icons.south_west_rounded,
                                activeColor: LiquidGlassTheme.surplusEmerald,
                                activeGradient:
                                    LiquidGlassTheme.surplusLiquidGradient,
                              ),
                              _buildTypeTab(
                                type: TransactionType.expense,
                                label: 'Pengeluaran',
                                icon: Icons.north_east_rounded,
                                activeColor: LiquidGlassTheme.defisitRose,
                                activeGradient:
                                    LiquidGlassTheme.defisitLiquidGradient,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Amount Card
                    LiquidGlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                size: 14,
                                color: activeThemeColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'NOMINAL TRANSAKSI',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 80,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [CurrencyInputFormatter()],
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: activeThemeColor,
                                  letterSpacing: -1,
                                ),
                                decoration: InputDecoration(
                                  prefixText: 'Rp ',
                                  prefixStyle: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        activeThemeColor.withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selector Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomDropdown(
                            context: context,
                            state: state,
                            label: 'Kategori',
                            value: _selectedCategory!,
                            items: currentCategories,
                            icon: Icons.category_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Actor Selector
                    _buildActorDropdown(context),
                    const SizedBox(height: 14),

                    // Note Input
                    LiquidGlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      child: TextFormField(
                        controller: _noteController,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.sticky_note_2_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 18,
                          ),
                          labelText: 'Catatan Opsional',
                          labelStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Struk Photo Container
                    if (!widget.isInitialBalance) _buildReceiptContainer(),

                    const SizedBox(height: 32),

                    // Save Button
                    LiquidGlassButton(
                      onPressed: () => _save(context),
                      label: widget.isInitialBalance
                          ? 'Inject Saldo Sekarang'
                          : 'Simpan Transaksi',
                      icon: Icons.check_circle_rounded,
                      isFullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: 28,
                      gradient: widget.isInitialBalance
                          ? LiquidGlassTheme.aquaLiquidGradient
                          : (isIncome
                              ? LiquidGlassTheme.surplusLiquidGradient
                              : LiquidGlassTheme.primaryLiquidGradient),
                      glowColor: widget.isInitialBalance
                          ? LiquidGlassTheme.secondaryCyan
                          : (isIncome
                              ? LiquidGlassTheme.surplusEmerald
                              : LiquidGlassTheme.primaryViolet),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeTab({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color activeColor,
    required Gradient activeGradient,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedCategory = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required BuildContext context,
    required FinanceLoaded state,
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
  }) {
    return LiquidGlassSelectorTile(
      label: label,
      value: value,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (_selectedType == TransactionType.income
                  ? LiquidGlassTheme.surplusEmerald
                  : LiquidGlassTheme.primaryViolet)
              .withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: _selectedType == TransactionType.income
              ? LiquidGlassTheme.surplusEmerald
              : LiquidGlassTheme.primaryVioletLight,
          size: 18,
        ),
      ),
      enabled: !widget.isInitialBalance,
      onTap: () => _showCategoryPickerModal(context, state),
    );
  }

  void _showCategoryPickerModal(BuildContext context, FinanceLoaded state) {
    final isIncome = _selectedType == TransactionType.income;
    final activeColor = isIncome
        ? LiquidGlassTheme.surplusEmerald
        : LiquidGlassTheme.primaryVioletLight;
    final activeGradient = isIncome
        ? LiquidGlassTheme.surplusLiquidGradient
        : LiquidGlassTheme.primaryLiquidGradient;

    final categories =
        isIncome ? state.incomeCategories : state.expenseCategories;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return LiquidGlassContainer(
          borderRadius: 32,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Grabber
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: activeGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Kategori ${isIncome ? "Pemasukan" : "Pengeluaran"} Keluarga',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LiquidGlassBackButton(
                    icon: Icons.close_rounded,
                    size: 34,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 14),

              // Category List
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: isSelected ? activeGradient : null,
                            color: isSelected
                                ? null
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.07),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isIncome
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Action to Add Category
              LiquidGlassButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddCategoryDialog(context, state);
                },
                label: 'Tambah Kategori Baru',
                icon: Icons.add_rounded,
                isFullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                borderRadius: 20,
                gradient: activeGradient,
                glowColor: activeColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActorDropdown(BuildContext context) {
    return LiquidGlassSelectorTile(
      label: 'Penanggung Jawab',
      value: _selectedActor.fullName,
      leading: FamilyActorBadge(
        fullName: _selectedActor.fullName,
        size: 28,
      ),
      onTap: () => _showActorPickerModal(context),
    );
  }

  void _showActorPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return LiquidGlassContainer(
          borderRadius: 32,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grabber
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LiquidGlassTheme.primaryLiquidGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: LiquidGlassTheme.primaryViolet
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Penanggung Jawab',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Pilih anggota keluarga yang mencatat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LiquidGlassBackButton(
                    icon: Icons.close_rounded,
                    size: 34,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 14),

              // Actor Cards
              ...Actor.values.map((actor) {
                final isSelected = actor == _selectedActor;
                final isHidayat = actor == Actor.hidayatullah;
                final actorColor = isHidayat
                    ? LiquidGlassTheme.actorHidayat
                    : LiquidGlassTheme.actorDeasy;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedActor = actor);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? actorColor.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? actorColor.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          FamilyActorBadge(
                            fullName: actor.fullName,
                            size: 36,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  actor.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isHidayat
                                      ? 'Kepala Keluarga'
                                      : 'Bendahara Keluarga',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: actorColor,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptContainer() {
    return GestureDetector(
      onTap: _pickImage,
      child: LiquidGlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        borderColor: _imagePath != null
            ? LiquidGlassTheme.surplusEmerald.withValues(alpha: 0.4)
            : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _imagePath != null
                    ? LiquidGlassTheme.surplusEmerald.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _imagePath != null
                      ? LiquidGlassTheme.surplusEmerald.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                _imagePath != null
                    ? Icons.check_circle_rounded
                    : Icons.camera_alt_rounded,
                color: _imagePath != null
                    ? LiquidGlassTheme.surplusEmerald
                    : LiquidGlassTheme.primaryVioletLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _imagePath != null
                        ? 'Bukti Struk Tersimpan'
                        : 'Foto Struk Belanja',
                    style: TextStyle(
                      color: _imagePath != null
                          ? LiquidGlassTheme.surplusEmerald
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _imagePath != null
                        ? 'Ketuk untuk mengambil ulang'
                        : 'Ketuk untuk membuka kamera',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_imagePath != null)
              LiquidGlassIconButton(
                size: 32,
                icon: Icons.delete_outline_rounded,
                iconColor: LiquidGlassTheme.defisitRose,
                onPressed: () => setState(() => _imagePath = null),
              ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final amountString =
        _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountString) ?? 0;

    if (amount <= 0 || _selectedCategory == null) return;

    final tx = TransactionEntity(
      id: const Uuid().v4(),
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory!,
      note: _noteController.text,
      actor: _selectedActor,
      type: _selectedType,
      receiptImagePath: _imagePath,
    );

    context.read<FinanceBloc>().add(AddTransactionEvent(tx));
    Navigator.pop(context);
  }
}
