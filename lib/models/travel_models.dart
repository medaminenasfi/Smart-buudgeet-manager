enum TravelExpenseCategory {
  accommodation,
  food,
  transportation,
  activities,
  shopping,
  other,
}

enum TripStatus {
  planning,
  active,
  completed,
}

class Trip {
  final String id;
  final String destination;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.destination,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      destination: map['destination'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(map['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['end_date'] ?? DateTime.now().toIso8601String()),
      status: TripStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'planning'),
        orElse: () => TripStatus.planning,
      ),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'budget': budget,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Trip copyWith({
    String? id,
    String? destination,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TravelExpense {
  final String id;
  final String tripId;
  final String description;
  final double amount;
  final TravelExpenseCategory category;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  TravelExpense({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  factory TravelExpense.fromMap(Map<String, dynamic> map) {
    return TravelExpense(
      id: map['id'] ?? '',
      tripId: map['trip_id'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: TravelExpenseCategory.values.firstWhere(
        (c) => c.name == (map['category'] ?? 'food'),
        orElse: () => TravelExpenseCategory.food,
      ),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'description': description,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TravelExpense copyWith({
    String? id,
    String? tripId,
    String? description,
    double? amount,
    TravelExpenseCategory? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TravelExpense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TravelBudget {
  final String id;
  final String tripId;
  final double accommodationBudget;
  final double foodBudget;
  final double transportationBudget;
  final double activitiesBudget;
  final double shoppingBudget;
  final double otherBudget;
  final DateTime createdAt;

  TravelBudget({
    required this.id,
    required this.tripId,
    this.accommodationBudget = 0.0,
    this.foodBudget = 0.0,
    this.transportationBudget = 0.0,
    this.activitiesBudget = 0.0,
    this.shoppingBudget = 0.0,
    this.otherBudget = 0.0,
    required this.createdAt,
  });

  double get totalBudget {
    return accommodationBudget +
        foodBudget +
        transportationBudget +
        activitiesBudget +
        shoppingBudget +
        otherBudget;
  }

  double getBudgetForCategory(TravelExpenseCategory category) {
    switch (category) {
      case TravelExpenseCategory.accommodation:
        return accommodationBudget;
      case TravelExpenseCategory.food:
        return foodBudget;
      case TravelExpenseCategory.transportation:
        return transportationBudget;
      case TravelExpenseCategory.activities:
        return activitiesBudget;
      case TravelExpenseCategory.shopping:
        return shoppingBudget;
      case TravelExpenseCategory.other:
        return otherBudget;
    }
  }

  factory TravelBudget.fromMap(Map<String, dynamic> map) {
    return TravelBudget(
      id: map['id'] ?? '',
      tripId: map['trip_id'] ?? '',
      accommodationBudget: (map['accommodation_budget'] ?? 0.0).toDouble(),
      foodBudget: (map['food_budget'] ?? 0.0).toDouble(),
      transportationBudget: (map['transportation_budget'] ?? 0.0).toDouble(),
      activitiesBudget: (map['activities_budget'] ?? 0.0).toDouble(),
      shoppingBudget: (map['shopping_budget'] ?? 0.0).toDouble(),
      otherBudget: (map['other_budget'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'accommodation_budget': accommodationBudget,
      'food_budget': foodBudget,
      'transportation_budget': transportationBudget,
      'activities_budget': activitiesBudget,
      'shopping_budget': shoppingBudget,
      'other_budget': otherBudget,
      'created_at': createdAt.toIso8601String(),
    };
  }
}