import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/travel_models.dart';

class TravelProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<Trip> _trips = [];
  List<TravelExpense> _expenses = [];
  Trip? _currentTrip;
  bool _isLoading = false;

  // Web storage fallback
  final Map<String, Trip> _webTrips = {};
  final Map<String, TravelExpense> _webExpenses = {};

  List<Trip> get trips => _trips;
  List<TravelExpense> get expenses => _expenses;
  Trip? get currentTrip => _currentTrip;
  bool get isLoading => _isLoading;

  double get totalSpent {
    if (_currentTrip == null) return 0.0;
    return _expenses
        .where((expense) => expense.tripId == _currentTrip!.id)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<TravelExpenseCategory, double> getCategorySpending() {
    if (_currentTrip == null) return {};
    
    final categorySpending = <TravelExpenseCategory, double>{};
    
    for (final category in TravelExpenseCategory.values) {
      categorySpending[category] = 0.0;
    }
    
    final currentTripExpenses = _expenses
        .where((expense) => expense.tripId == _currentTrip!.id);
    
    for (final expense in currentTripExpenses) {
      categorySpending[expense.category] = 
          (categorySpending[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categorySpending;
  }

  Future<void> loadTravelData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final currentMonth = '${now.month.toString().padLeft(2, '0')}/${now.year}';
      
      debugPrint('Loading travel data for $currentMonth');

      if (kIsWeb) {
        debugPrint('Web platform detected - using in-memory storage');
        
        // Load from web storage
        _trips = _webTrips.values.toList();
        _expenses = _webExpenses.values.toList();
        
        // Find current active trip
        _currentTrip = _trips.where((trip) => 
          trip.status == TripStatus.active || trip.status == TripStatus.planning
        ).isNotEmpty ? _trips.where((trip) => 
          trip.status == TripStatus.active || trip.status == TripStatus.planning
        ).first : null;
        
        await Future.delayed(const Duration(milliseconds: 500));
        
      } else {
        // Load from SQLite database
        final database = await _databaseHelper.database;
        
        // Load trips
        final tripsResult = await database.query('trips');
        _trips = tripsResult.map((map) => Trip.fromMap(map)).toList();
        
        // Load expenses
        final expensesResult = await database.query('travel_expenses');
        _expenses = expensesResult.map((map) => TravelExpense.fromMap(map)).toList();
        
        // Find current active trip
        _currentTrip = _trips.where((trip) => 
          trip.status == TripStatus.active || trip.status == TripStatus.planning
        ).isNotEmpty ? _trips.where((trip) => 
          trip.status == TripStatus.active || trip.status == TripStatus.planning
        ).first : null;
      }

      debugPrint('Trips loaded: ${_trips.length} trips');
      debugPrint('Expenses loaded: ${_expenses.length} expenses');
      debugPrint('Current trip: ${_currentTrip?.destination ?? 'None'}');
      
    } catch (e) {
      debugPrint('Database operation failed: $e');
      // Initialize with empty data
      _trips = [];
      _expenses = [];
      _currentTrip = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTrip(
    String destination,
    double budget,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final tripId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final trip = Trip(
      id: tripId,
      destination: destination,
      budget: budget,
      startDate: startDate,
      endDate: endDate,
      status: TripStatus.active,
      createdAt: DateTime.now(),
    );

    try {
      if (kIsWeb) {
        // Complete any existing active trip
        for (final existingTrip in _webTrips.values) {
          if (existingTrip.status == TripStatus.active) {
            _webTrips[existingTrip.id] = existingTrip.copyWith(status: TripStatus.completed);
          }
        }
        
        _webTrips[tripId] = trip;
        _trips = _webTrips.values.toList();
        _currentTrip = trip;
        
      } else {
        final database = await _databaseHelper.database;
        
        // Complete any existing active trip
        await database.update(
          'trips',
          {'status': TripStatus.completed.name},
          where: 'status = ?',
          whereArgs: [TripStatus.active.name],
        );
        
        await database.insert('trips', trip.toMap());
        _trips.add(trip);
        _currentTrip = trip;
      }

      debugPrint('Trip created: ${trip.destination}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error creating trip: $e');
    }
  }

  Future<void> updateTrip(
    String tripId,
    String destination,
    double budget,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (kIsWeb) {
        final existingTrip = _webTrips[tripId];
        if (existingTrip != null) {
          final updatedTrip = existingTrip.copyWith(
            destination: destination,
            budget: budget,
            startDate: startDate,
            endDate: endDate,
          );
          
          _webTrips[tripId] = updatedTrip;
          _trips = _webTrips.values.toList();
          
          if (_currentTrip?.id == tripId) {
            _currentTrip = updatedTrip;
          }
        }
        
      } else {
        final database = await _databaseHelper.database;
        
        await database.update(
          'trips',
          {
            'destination': destination,
            'budget': budget,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [tripId],
        );
        
        final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
        if (tripIndex != -1) {
          _trips[tripIndex] = _trips[tripIndex].copyWith(
            destination: destination,
            budget: budget,
            startDate: startDate,
            endDate: endDate,
          );
          
          if (_currentTrip?.id == tripId) {
            _currentTrip = _trips[tripIndex];
          }
        }
      }

      debugPrint('Trip updated: $destination');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error updating trip: $e');
    }
  }

  Future<void> completeTrip(String tripId) async {
    try {
      if (kIsWeb) {
        final existingTrip = _webTrips[tripId];
        if (existingTrip != null) {
          _webTrips[tripId] = existingTrip.copyWith(status: TripStatus.completed);
          _trips = _webTrips.values.toList();
          
          if (_currentTrip?.id == tripId) {
            _currentTrip = null;
          }
        }
        
      } else {
        final database = await _databaseHelper.database;
        
        await database.update(
          'trips',
          {'status': TripStatus.completed.name},
          where: 'id = ?',
          whereArgs: [tripId],
        );
        
        final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
        if (tripIndex != -1) {
          _trips[tripIndex] = _trips[tripIndex].copyWith(status: TripStatus.completed);
          
          if (_currentTrip?.id == tripId) {
            _currentTrip = null;
          }
        }
      }

      debugPrint('Trip completed: $tripId');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error completing trip: $e');
    }
  }

  Future<void> addExpense(
    String description,
    double amount,
    TravelExpenseCategory category,
    DateTime date,
    {String notes = ''}
  ) async {
    if (_currentTrip == null) return;
    
    final expenseId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final expense = TravelExpense(
      id: expenseId,
      tripId: _currentTrip!.id,
      description: description,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      createdAt: DateTime.now(),
    );

    try {
      if (kIsWeb) {
        _webExpenses[expenseId] = expense;
        _expenses = _webExpenses.values.toList();
        
      } else {
        final database = await _databaseHelper.database;
        await database.insert('travel_expenses', expense.toMap());
        _expenses.add(expense);
      }

      // Sort expenses by date (newest first)
      _expenses.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Expense added: $description - \$${amount.toStringAsFixed(2)}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      if (kIsWeb) {
        _webExpenses.remove(expenseId);
        _expenses = _webExpenses.values.toList();
        
      } else {
        final database = await _databaseHelper.database;
        await database.delete(
          'travel_expenses',
          where: 'id = ?',
          whereArgs: [expenseId],
        );
        
        _expenses.removeWhere((expense) => expense.id == expenseId);
      }

      debugPrint('Expense deleted: $expenseId');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }

  Future<void> updateExpense(
    String expenseId,
    String description,
    double amount,
    TravelExpenseCategory category,
    DateTime date,
    {String notes = ''}
  ) async {
    try {
      if (kIsWeb) {
        final existingExpense = _webExpenses[expenseId];
        if (existingExpense != null) {
          _webExpenses[expenseId] = existingExpense.copyWith(
            description: description,
            amount: amount,
            category: category,
            date: date,
            notes: notes,
          );
          _expenses = _webExpenses.values.toList();
        }
        
      } else {
        final database = await _databaseHelper.database;
        
        await database.update(
          'travel_expenses',
          {
            'description': description,
            'amount': amount,
            'category': category.name,
            'date': date.toIso8601String(),
            'notes': notes,
          },
          where: 'id = ?',
          whereArgs: [expenseId],
        );
        
        final expenseIndex = _expenses.indexWhere((expense) => expense.id == expenseId);
        if (expenseIndex != -1) {
          _expenses[expenseIndex] = _expenses[expenseIndex].copyWith(
            description: description,
            amount: amount,
            category: category,
            date: date,
            notes: notes,
          );
        }
      }

      // Sort expenses by date (newest first)
      _expenses.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Expense updated: $description - \$${amount.toStringAsFixed(2)}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error updating expense: $e');
    }
  }

  List<TravelExpense> getExpensesForTrip(String tripId) {
    return _expenses.where((expense) => expense.tripId == tripId).toList();
  }

  double getTotalSpentForTrip(String tripId) {
    return getExpensesForTrip(tripId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<TravelExpenseCategory, double> getCategorySpendingForTrip(String tripId) {
    final categorySpending = <TravelExpenseCategory, double>{};
    
    for (final category in TravelExpenseCategory.values) {
      categorySpending[category] = 0.0;
    }
    
    final tripExpenses = getExpensesForTrip(tripId);
    
    for (final expense in tripExpenses) {
      categorySpending[expense.category] = 
          (categorySpending[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categorySpending;
  }
}