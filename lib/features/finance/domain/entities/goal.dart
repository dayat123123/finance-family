class GoalEntity {
  final String id;
  final String title;
  final double targetAmount;
  final String iconName;
  final double allocationPercentage; // e.g. 80.0 for 80%

  GoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.iconName = 'home',
    this.allocationPercentage = 0.0,
  });
}
