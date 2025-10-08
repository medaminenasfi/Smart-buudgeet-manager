import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../database/database_extensions.dart';

class TravelBudgetProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<TravelBudget> _travelBudgets = [];
  TravelBudget? _selectedBudget;
  List<TravelExpense> _expenses = [];
  Map<String, double> _expensesByCategory = {};
  bool _isLoading = false;
  
  // Getters
  List<TravelBudget> get travelBudgets => _travelBudgets;
  TravelBudget? get selectedBudget => _selectedBudget;
  List<TravelExpense> get expenses => _expenses;
  Map<String, double> get expensesByCategory => _expensesByCategory;
  bool get isLoading => _isLoading;
  
  double get totalSpent {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
  
  double get remainingBudget {
    if (_selectedBudget == null) return 0.0;
    return _selectedBudget!.amount - totalSpent;
  }
  
  double get budgetPercentageUsed {
    if (_selectedBudget == null || _selectedBudget!.amount == 0) return 0.0;
    return (totalSpent / _selectedBudget!.amount) * 100;
  }

  // Load all travel budgets
  Future<void> loadTravelBudgets() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _travelBudgets = await _databaseHelper.getTravelBudgets();
    } catch (e) {
      debugPrint('Error loading travel budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a specific travel budget and load its expenses
  Future<void> selectTravelBudget(int travelBudgetId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _selectedBudget = await _databaseHelper.getTravelBudgetById(travelBudgetId);
      _expenses = await _databaseHelper.getTravelExpenses(travelBudgetId);
      _expensesByCategory = await _databaseHelper.getTravelExpensesByCategory(travelBudgetId);
    } catch (e) {
      debugPrint('Error selecting travel budget: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new travel budget
  Future<bool> createTravelBudget(String destination, double amount, DateTime startDate, DateTime endDate) async {
    try {
      final budget = TravelBudget(
        destination: destination,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
      );
      
      final id = await _databaseHelper.insertTravelBudget(budget);
      
      final newBudget = TravelBudget(
        id: id,
        destination: destination,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
      );
      
      _travelBudgets.insert(0, newBudget);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating travel budget: $e');
      return false;
    }
  }

  // Update travel budget
  Future<bool> updateTravelBudget(TravelBudget budget) async {
    try {
      await _databaseHelper.updateTravelBudget(budget);
      
      final index = _travelBudgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _travelBudgets[index] = budget;
        if (_selectedBudget?.id == budget.id) {
          _selectedBudget = budget;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating travel budget: $e');
      return false;
    }
  }

  // Delete travel budget
  Future<bool> deleteTravelBudget(int budgetId) async {
    try {
      await _databaseHelper.deleteTravelBudget(budgetId);
      
      _travelBudgets.removeWhere((budget) => budget.id == budgetId);
      
      if (_selectedBudget?.id == budgetId) {
        _selectedBudget = null;
        _expenses.clear();
        _expensesByCategory.clear();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting travel budget: $e');
      return false;
    }
  }

  // Add travel expense
  Future<bool> addExpense(String category, double amount, DateTime date, {String? description}) async {
    if (_selectedBudget == null) return false;
    
    try {
      final expense = TravelExpense(
        travelBudgetId: _selectedBudget!.id!,
        category: category,
        amount: amount,
        date: date,
        description: description,
      );
      
      final id = await _databaseHelper.insertTravelExpense(expense);
      
      final newExpense = TravelExpense(
        id: id,
        travelBudgetId: _selectedBudget!.id!,
        category: category,
        amount: amount,
        date: date,
        description: description,
      );
      
      _expenses.insert(0, newExpense);
      
      // Update category totals
      _expensesByCategory[category] = (_expensesByCategory[category] ?? 0.0) + amount;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding travel expense: $e');
      return false;
    }
  }

  // Update travel expense
  Future<bool> updateExpense(TravelExpense expense) async {
    try {
      await _databaseHelper.updateTravelExpense(expense);
      
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        final oldExpense = _expenses[index];
        _expenses[index] = expense;
        
        // Update category totals
        _expensesByCategory[oldExpense.category] = 
            (_expensesByCategory[oldExpense.category] ?? 0.0) - oldExpense.amount;
        _expensesByCategory[expense.category] = 
            (_expensesByCategory[expense.category] ?? 0.0) + expense.amount;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating travel expense: $e');
      return false;
    }
  }

  // Delete travel expense
  Future<bool> deleteExpense(int expenseId) async {
    try {
      await _databaseHelper.deleteTravelExpense(expenseId);
      
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      
      // Update category totals
      _expensesByCategory[expense.category] = 
          (_expensesByCategory[expense.category] ?? 0.0) - expense.amount;
      
      if (_expensesByCategory[expense.category]! <= 0) {
        _expensesByCategory.remove(expense.category);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting travel expense: $e');
      return false;
    }
  }

  // Get expenses for a specific category
  List<TravelExpense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Clear selected budget data
  void clearSelectedBudget() {
    _selectedBudget = null;
    _expenses.clear();
    _expensesByCategory.clear();
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _travelBudgets.clear();
    _selectedBudget = null;
    _expenses.clear();
    _expensesByCategory.clear();
    notifyListeners();
  }
}