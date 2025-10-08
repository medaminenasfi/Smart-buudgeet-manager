enum SavingsGoalStatus {
  active,
  completed,
  paused,
}

enum SavingsGoalPriority {
  low,
  medium,
  high,
  urgent,
}

enum SavingsGoalCategory {
  emergency,
  vacation,
  house,
  car,
  education,
  retirement,
  investment,
  gadgets,
  other,
}

class SavingsGoal {
  final String id;
  final String name;
  final String description;
  final double targetAmount;
  final DateTime targetDate;
  final SavingsGoalCategory category;
  final SavingsGoalPriority priority;
  final SavingsGoalStatus status;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    this.description = '',
    required this.targetAmount,
    required this.targetDate,
    required this.category,
    this.priority = SavingsGoalPriority.medium,
    this.status = SavingsGoalStatus.active,
    required this.createdAt,
  });

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetAmount: (map['target_amount'] ?? 0.0).toDouble(),
      targetDate: DateTime.parse(map['target_date'] ?? DateTime.now().toIso8601String()),
      category: SavingsGoalCategory.values.firstWhere(
        (c) => c.name == (map['category'] ?? 'other'),
        orElse: () => SavingsGoalCategory.other,
      ),
      priority: SavingsGoalPriority.values.firstWhere(
        (p) => p.name == (map['priority'] ?? 'medium'),
        orElse: () => SavingsGoalPriority.medium,
      ),
      status: SavingsGoalStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'active'),
        orElse: () => SavingsGoalStatus.active,
      ),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'target_date': targetDate.toIso8601String(),
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    DateTime? targetDate,
    SavingsGoalCategory? category,
    SavingsGoalPriority? priority,
    SavingsGoalStatus? status,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool get isActive => status == SavingsGoalStatus.active;
  bool get isCompleted => status == SavingsGoalStatus.completed;
  bool get isPaused => status == SavingsGoalStatus.paused;
  
  int get daysUntilTarget {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }
  
  bool get isOverdue {
    return targetDate.isBefore(DateTime.now()) && !isCompleted;
  }
}

class SavingsRecord {
  final String id;
  final String goalId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  SavingsRecord({
    required this.id,
    required this.goalId,
    required this.amount,
    this.description = '',
    required this.date,
    required this.createdAt,
  });

  factory SavingsRecord.fromMap(Map<String, dynamic> map) {
    return SavingsRecord(
      id: map['id'] ?? '',
      goalId: map['goal_id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavingsRecord copyWith({
    String? id,
    String? goalId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return SavingsRecord(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SavingsGoalWithProgress {
  final SavingsGoal goal;
  final double currentAmount;
  final List<SavingsRecord> records;

  SavingsGoalWithProgress({
    required this.goal,
    required this.currentAmount,
    required this.records,
  });

  double get progressPercentage {
    if (goal.targetAmount <= 0) return 0.0;
    return (currentAmount / goal.targetAmount * 100).clamp(0.0, 100.0);
  }

  double get remainingAmount {
    return (goal.targetAmount - currentAmount).clamp(0.0, goal.targetAmount);
  }

  bool get isCompleted => currentAmount >= goal.targetAmount;

  String get formattedProgress {
    return '${currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}';
  }

  double get monthlyRequiredSavings {
    if (goal.isCompleted || goal.daysUntilTarget <= 0) return 0.0;
    final monthsRemaining = goal.daysUntilTarget / 30.0;
    if (monthsRemaining <= 0) return remainingAmount;
    return remainingAmount / monthsRemaining;
  }
}