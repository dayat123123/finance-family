import '../entities/transaction.dart';
import '../entities/goal.dart';
import '../entities/budget_plan.dart';
import '../repositories/finance_repository.dart';

class ManageFinanceUseCase {
  final FinanceRepository repository;
  ManageFinanceUseCase(this.repository);

  Future<List<TransactionEntity>> executeGetTransactions() async => await repository.getTransactions();
  Future<void> executeAddTransaction(TransactionEntity transaction) async => await repository.saveTransaction(transaction);
  Future<void> executeDeleteTransaction(String id) async => await repository.deleteTransaction(id);

  Future<List<GoalEntity>> executeGetGoals() async => await repository.getGoals();
  Future<void> executeSaveGoal(GoalEntity goal) async => await repository.saveGoal(goal);
  Future<void> executeDeleteGoal(String id) async => await repository.deleteGoal(id);

  Future<List<BudgetPlanEntity>> executeGetBudgetPlans() async => await repository.getBudgetPlans();
  Future<void> executeSaveBudgetPlan(BudgetPlanEntity plan) async => await repository.saveBudgetPlan(plan);
  Future<void> executeDeleteBudgetPlan(String id) async => await repository.deleteBudgetPlan(id);

  Future<List<String>> executeGetCategories(TransactionType type) async => await repository.getCategories(type);
  Future<void> executeAddCategory(TransactionType type, String category) async => await repository.addCategory(type, category);
}
