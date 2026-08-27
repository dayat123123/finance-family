class GoalEntity {
  final String id;
  final String title;
  final double targetAmount;
  final String iconName;

  GoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.iconName = 'home',
  });
}
