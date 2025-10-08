class MonthlyBudget {
  final int? id;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;

  MonthlyBudget({
    this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'],
      amount: map['amount'].toDouble(),
      month: map['month'],
      year: map['year'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class MonthlyExpense {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;

  MonthlyExpense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory MonthlyExpense.fromMap(Map<String, dynamic> map) {
    return MonthlyExpense(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}