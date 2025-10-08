class TravelBudget {
  final int? id;
  final String destination;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  TravelBudget({
    this.id,
    required this.destination,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TravelBudget.fromMap(Map<String, dynamic> map) {
    return TravelBudget(
      id: map['id'],
      destination: map['destination'],
      amount: map['amount'].toDouble(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class TravelExpense {
  final int? id;
  final int travelBudgetId;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;

  TravelExpense({
    this.id,
    required this.travelBudgetId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travel_budget_id': travelBudgetId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory TravelExpense.fromMap(Map<String, dynamic> map) {
    return TravelExpense(
      id: map['id'],
      travelBudgetId: map['travel_budget_id'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}