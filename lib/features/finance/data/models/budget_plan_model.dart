import '../../domain/entities/budget_plan.dart';

class BudgetPlanModel extends BudgetPlanEntity {
  BudgetPlanModel({
    required super.id,
    required super.title,
    required super.allocatedBudget,
    required super.spentAmount,
    required super.category,
  });

  factory BudgetPlanModel.fromJson(Map<String, dynamic> json) {
    return BudgetPlanModel(
      id: json['id'],
      title: json['title'],
      allocatedBudget: (json['allocatedBudget'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'allocatedBudget': allocatedBudget,
    'spentAmount': spentAmount,
    'category': category,
  };

  factory BudgetPlanModel.fromEntity(BudgetPlanEntity entity) => BudgetPlanModel(
    id: entity.id,
    title: entity.title,
    allocatedBudget: entity.allocatedBudget,
    spentAmount: entity.spentAmount,
    category: entity.category,
  );
}
