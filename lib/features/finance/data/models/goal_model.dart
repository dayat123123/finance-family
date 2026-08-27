import '../../domain/entities/goal.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required super.id,
    required super.title,
    required super.targetAmount,
    required super.iconName,
    super.allocationPercentage = 0.0,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      iconName: json['iconName'] ?? 'home',
      allocationPercentage: json['allocationPercentage'] != null
          ? (json['allocationPercentage'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'iconName': iconName,
    'allocationPercentage': allocationPercentage,
  };

  factory GoalModel.fromEntity(GoalEntity entity) => GoalModel(
    id: entity.id,
    title: entity.title,
    targetAmount: entity.targetAmount,
    iconName: entity.iconName,
    allocationPercentage: entity.allocationPercentage,
  );
}
