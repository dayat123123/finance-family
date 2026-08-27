import '../../domain/entities/goal.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required super.id,
    required super.title,
    required super.targetAmount,
    required super.iconName,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      iconName: json['iconName'] ?? 'home',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'iconName': iconName,
  };

  factory GoalModel.fromEntity(GoalEntity entity) => GoalModel(
    id: entity.id,
    title: entity.title,
    targetAmount: entity.targetAmount,
    iconName: entity.iconName,
  );
}
