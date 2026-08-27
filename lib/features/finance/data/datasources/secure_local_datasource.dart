import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/budget_plan_model.dart';
import '../../domain/entities/transaction.dart';

abstract class SecureLocalDataSource {
  Future<List<TransactionModel>> fetchTransactions();
  Future<void> saveTransactions(List<TransactionModel> transactions);
  
  Future<List<GoalModel>> fetchGoals();
  Future<void> saveGoals(List<GoalModel> goals);

  Future<List<BudgetPlanModel>> fetchBudgetPlans();
  Future<void> saveBudgetPlans(List<BudgetPlanModel> plans);

  Future<List<String>> fetchCategories(TransactionType type);
  Future<void> saveCategories(TransactionType type, List<String> categories);
}

class SecureLocalDataSourceImpl implements SecureLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _txKey = 'FINANCE_TX_STRICT_DEL_V5';
  static const String _goalKey = 'FINANCE_GOAL_STRICT_DEL_V5';
  static const String _budgetKey = 'FINANCE_BUDGET_STRICT_DEL_V5';
  static const String _catExpenseKey = 'FINANCE_CAT_EXP_V5';
  static const String _catIncomeKey = 'FINANCE_CAT_INC_V5';

  SecureLocalDataSourceImpl(this.secureStorage);

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final dataString = await secureStorage.read(key: _txKey);
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(dataString);
      return decoded.map((e) => TransactionModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    await secureStorage.write(key: _txKey, value: jsonEncode(transactions.map((e) => e.toJson()).toList()));
  }

  @override
  Future<List<GoalModel>> fetchGoals() async {
    final dataString = await secureStorage.read(key: _goalKey);
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(dataString);
      return decoded.map((e) => GoalModel.fromJson(e)).toList();
    }
    return [
      GoalModel(id: 'dp_rumah_jkt', title: 'DP Rumah Jakarta', targetAmount: 100000000, iconName: 'home')
    ];
  }

  @override
  Future<void> saveGoals(List<GoalModel> goals) async {
    await secureStorage.write(key: _goalKey, value: jsonEncode(goals.map((e) => e.toJson()).toList()));
  }

  @override
  Future<List<BudgetPlanModel>> fetchBudgetPlans() async {
    final dataString = await secureStorage.read(key: _budgetKey);
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(dataString);
      return decoded.map((e) => BudgetPlanModel.fromJson(e)).toList();
    }
    return [
      BudgetPlanModel(id: 'holiday_plan', title: 'Rencana Liburan Akhir Tahun', allocatedBudget: 5000000, spentAmount: 0, category: 'Hiburan')
    ];
  }

  @override
  Future<void> saveBudgetPlans(List<BudgetPlanModel> plans) async {
    await secureStorage.write(key: _budgetKey, value: jsonEncode(plans.map((e) => e.toJson()).toList()));
  }

  @override
  Future<List<String>> fetchCategories(TransactionType type) async {
    final key = type == TransactionType.income ? _catIncomeKey : _catExpenseKey;
    final dataString = await secureStorage.read(key: key);
    if (dataString != null && dataString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(dataString);
      return decoded.map((e) => e.toString()).toList();
    }
    if (type == TransactionType.income) {
      return ['Gaji Pokok', 'Bonus/Lembur', 'Investasi'];
    } else {
      return ['Dapur & Belanja', 'Skincare & Bodycare', 'Transportasi', 'Hiburan', 'Tagihan', 'Lainnya'];
    }
  }

  @override
  Future<void> saveCategories(TransactionType type, List<String> categories) async {
    final key = type == TransactionType.income ? _catIncomeKey : _catExpenseKey;
    await secureStorage.write(key: key, value: jsonEncode(categories));
  }
}
