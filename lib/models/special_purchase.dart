class SpecialBudget {
  final int? id;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;

  SpecialBudget({
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

  factory SpecialBudget.fromMap(Map<String, dynamic> map) {
    return SpecialBudget(
      id: map['id'],
      amount: map['amount'].toDouble(),
      month: map['month'],
      year: map['year'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class SpecialItem {
  final int? id;
  final String name;
  final double estimatedCost;
  final bool isPurchased;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final String? description;

  SpecialItem({
    this.id,
    required this.name,
    required this.estimatedCost,
    this.isPurchased = false,
    this.purchaseDate,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'estimated_cost': estimatedCost,
      'is_purchased': isPurchased ? 1 : 0,
      'purchase_date': purchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory SpecialItem.fromMap(Map<String, dynamic> map) {
    return SpecialItem(
      id: map['id'],
      name: map['name'],
      estimatedCost: map['estimated_cost'].toDouble(),
      isPurchased: map['is_purchased'] == 1,
      purchaseDate: map['purchase_date'] != null 
          ? DateTime.parse(map['purchase_date']) 
          : null,
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
    );
  }
}