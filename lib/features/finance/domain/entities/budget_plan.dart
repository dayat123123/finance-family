class BudgetPlanEntity {
  final String id;
  final String title;
  final double allocatedBudget;
  final double spentAmount;
  final String category;

  BudgetPlanEntity({
    required this.id,
    required this.title,
    required this.allocatedBudget,
    required this.spentAmount,
    required this.category,
  });
}
