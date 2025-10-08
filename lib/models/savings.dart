class SavingsGoal {
  final int? id;
  final String goalName;
  final double targetAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? description;

  SavingsGoal({
    this.id,
    required this.goalName,
    required this.targetAmount,
    required this.targetDate,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_name': goalName,
      'target_amount': targetAmount,
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      goalName: map['goal_name'],
      targetAmount: map['target_amount'].toDouble(),
      targetDate: DateTime.parse(map['target_date']),
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
    );
  }
}

class SavingsRecord {
  final int? id;
  final int savingsGoalId;
  final double amount;
  final DateTime date;
  final String? description;

  SavingsRecord({
    this.id,
    required this.savingsGoalId,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'savings_goal_id': savingsGoalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory SavingsRecord.fromMap(Map<String, dynamic> map) {
    return SavingsRecord(
      id: map['id'],
      savingsGoalId: map['savings_goal_id'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}