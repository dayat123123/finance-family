import '../entities/transaction.dart';
import '../entities/goal.dart';
import '../entities/budget_plan.dart';

abstract class FinanceRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> saveTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  
  Future<List<GoalEntity>> getGoals();
  Future<void> saveGoal(GoalEntity goal);
  Future<void> deleteGoal(String id);
  
  Future<List<BudgetPlanEntity>> getBudgetPlans();
  Future<void> saveBudgetPlan(BudgetPlanEntity plan);
  Future<void> deleteBudgetPlan(String id);

  Future<List<String>> getCategories(TransactionType type);
  Future<void> addCategory(TransactionType type, String category);
}
