import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/budget_plan.dart';
import '../../domain/usecases/manage_finance_usecase.dart';

enum CashFlowStatus { surplus, defisit, balance }

abstract class FinanceEvent {}

class LoadDataEvent extends FinanceEvent {}

class ChangeMonthEvent extends FinanceEvent {
  final DateTime newMonth;
  ChangeMonthEvent(this.newMonth);
}

class AddTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;
  AddTransactionEvent(this.transaction);
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;
  DeleteTransactionEvent(this.id);
}

class AddGoalEvent extends FinanceEvent {
  final GoalEntity goal;
  AddGoalEvent(this.goal);
}

class EditGoalEvent extends FinanceEvent {
  final GoalEntity goal;
  EditGoalEvent(this.goal);
}

class DeleteGoalEvent extends FinanceEvent {
  final String id;
  DeleteGoalEvent(this.id);
}

class AddBudgetPlanEvent extends FinanceEvent {
  final BudgetPlanEntity plan;
  AddBudgetPlanEvent(this.plan);
}

class EditBudgetPlanEvent extends FinanceEvent {
  final BudgetPlanEntity plan;
  EditBudgetPlanEvent(this.plan);
}

class DeleteBudgetPlanEvent extends FinanceEvent {
  final String id;
  DeleteBudgetPlanEvent(this.id);
}

class AddCategoryEvent extends FinanceEvent {
  final TransactionType type;
  final String categoryName;
  AddCategoryEvent(this.type, this.categoryName);
}

abstract class FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<TransactionEntity> monthlyTransactions;
  final List<GoalEntity> goals;
  final List<BudgetPlanEntity> budgetPlans;
  final List<String> expenseCategories;
  final List<String> incomeCategories;
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyNetBalance;
  final CashFlowStatus cashFlowStatus;
  final DateTime selectedMonth;

  FinanceLoaded({
    required this.monthlyTransactions,
    required this.goals,
    required this.budgetPlans,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyNetBalance,
    required this.cashFlowStatus,
    required this.selectedMonth,
  });
}

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final ManageFinanceUseCase useCase;
  DateTime _currentMonth = DateTime.now();

  FinanceBloc(this.useCase) : super(FinanceLoading()) {
    on<LoadDataEvent>((event, emit) async {
      emit(FinanceLoading());
      await _processData(emit);
    });

    on<ChangeMonthEvent>((event, emit) async {
      _currentMonth = event.newMonth;
      await _processData(emit);
    });

    on<AddTransactionEvent>((event, emit) async {
      await useCase.executeAddTransaction(event.transaction);
      if (event.transaction.type != TransactionType.initialBalance) {
        _currentMonth = event.transaction.date;
      }
      await _processData(emit);
    });

    on<DeleteTransactionEvent>((event, emit) async {
      await useCase.executeDeleteTransaction(event.id);
      await _processData(emit);
    });

    on<AddGoalEvent>((event, emit) async {
      await useCase.executeSaveGoal(event.goal);
      await _processData(emit);
    });

    on<EditGoalEvent>((event, emit) async {
      await useCase.executeSaveGoal(event.goal);
      await _processData(emit);
    });

    on<DeleteGoalEvent>((event, emit) async {
      await useCase.executeDeleteGoal(event.id);
      await _processData(emit);
    });

    on<AddBudgetPlanEvent>((event, emit) async {
      await useCase.executeSaveBudgetPlan(event.plan);
      await _processData(emit);
    });

    on<EditBudgetPlanEvent>((event, emit) async {
      await useCase.executeSaveBudgetPlan(event.plan);
      await _processData(emit);
    });

    on<DeleteBudgetPlanEvent>((event, emit) async {
      await useCase.executeDeleteBudgetPlan(event.id);
      await _processData(emit);
    });

    on<AddCategoryEvent>((event, emit) async {
      await useCase.executeAddCategory(event.type, event.categoryName);
      await _processData(emit);
    });
  }

  Future<void> _processData(Emitter<FinanceState> emit) async {
    final txs = await useCase.executeGetTransactions();
    final goals = await useCase.executeGetGoals();
    final budgetPlans = await useCase.executeGetBudgetPlans();
    final expenseCats =
        await useCase.executeGetCategories(TransactionType.expense);
    final incomeCats =
        await useCase.executeGetCategories(TransactionType.income);

    double overallBalance = 0;

    final monthlyTxs = txs
        .where((t) =>
            t.date.year == _currentMonth.year &&
            t.date.month == _currentMonth.month &&
            t.type != TransactionType.initialBalance)
        .toList();

    double monthInc = 0;
    double monthExp = 0;

    for (var t in txs) {
      if (t.type == TransactionType.income ||
          t.type == TransactionType.initialBalance) {
        overallBalance += t.amount;
      }
      if (t.type == TransactionType.expense) overallBalance -= t.amount;
    }

    for (var t in monthlyTxs) {
      if (t.type == TransactionType.income) monthInc += t.amount;
      if (t.type == TransactionType.expense) monthExp += t.amount;
    }

    double netMonthly = monthInc - monthExp;

    CashFlowStatus status;
    if (netMonthly > 0) {
      status = CashFlowStatus.surplus;
    } else if (netMonthly < 0) {
      status = CashFlowStatus.defisit;
    } else {
      status = CashFlowStatus.balance;
    }

    emit(FinanceLoaded(
      monthlyTransactions: monthlyTxs,
      goals: goals,
      budgetPlans: budgetPlans,
      expenseCategories: expenseCats,
      incomeCategories: incomeCats,
      currentBalance: overallBalance > 0 ? overallBalance : 0,
      monthlyIncome: monthInc,
      monthlyExpense: monthExp,
      monthlyNetBalance: netMonthly,
      cashFlowStatus: status,
      selectedMonth: _currentMonth,
    ));
  }
}
