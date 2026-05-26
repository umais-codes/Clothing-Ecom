class CommissionRule {
  String id;
  String type;
  String targetName;
  double percentage;

  CommissionRule({
    required this.id,
    required this.type,
    required this.targetName,
    required this.percentage,
  });
}
