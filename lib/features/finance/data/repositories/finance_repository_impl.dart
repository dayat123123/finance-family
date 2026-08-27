import '../../domain/entities/transaction.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/budget_plan.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/secure_local_datasource.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/budget_plan_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final SecureLocalDataSource localDataSource;
  FinanceRepositoryImpl(this.localDataSource);

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await localDataSource.fetchTransactions();
    models.sort((a, b) => b.date.compareTo(a.date));
    return models;
  }

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    final models = await localDataSource.fetchTransactions();
    models.add(TransactionModel.fromEntity(transaction));
    await localDataSource.saveTransactions(models);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final models = await localDataSource.fetchTransactions();
    models.removeWhere((element) => element.id == id);
    await localDataSource.saveTransactions(models);
  }

  @override
  Future<List<GoalEntity>> getGoals() async {
    return await localDataSource.fetchGoals();
  }

  @override
  Future<void> saveGoal(GoalEntity goal) async {
    final models = await localDataSource.fetchGoals();
    final index = models.indexWhere((element) => element.id == goal.id);
    if (index >= 0) {
      models[index] = GoalModel.fromEntity(goal);
    } else {
      models.add(GoalModel.fromEntity(goal));
    }
    await localDataSource.saveGoals(models);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final models = await localDataSource.fetchGoals();
    models.removeWhere((element) => element.id == id);
    await localDataSource.saveGoals(models);
  }

  @override
  Future<List<BudgetPlanEntity>> getBudgetPlans() async {
    return await localDataSource.fetchBudgetPlans();
  }

  @override
  Future<void> saveBudgetPlan(BudgetPlanEntity plan) async {
    final models = await localDataSource.fetchBudgetPlans();
    final index = models.indexWhere((element) => element.id == plan.id);
    if (index >= 0) {
      models[index] = BudgetPlanModel.fromEntity(plan);
    } else {
      models.add(BudgetPlanModel.fromEntity(plan));
    }
    await localDataSource.saveBudgetPlans(models);
  }

  @override
  Future<void> deleteBudgetPlan(String id) async {
    final models = await localDataSource.fetchBudgetPlans();
    models.removeWhere((element) => element.id == id);
    await localDataSource.saveBudgetPlans(models);
  }

  @override
  Future<List<String>> getCategories(TransactionType type) async {
    return await localDataSource.fetchCategories(type);
  }

  @override
  Future<void> addCategory(TransactionType type, String category) async {
    final cats = await localDataSource.fetchCategories(type);
    if (!cats.contains(category)) {
      cats.add(category);
      await localDataSource.saveCategories(type, cats);
    }
  }
}
