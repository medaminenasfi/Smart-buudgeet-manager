import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../database/database_extensions.dart';

class MonthlyBudgetProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  MonthlyBudget? _currentBudget;
  List<MonthlyExpense> _expenses = [];
  Map<String, double> _expensesByCategory = {};
  bool _isLoading = false;
  
  // Web-only in-memory storage
  static final Map<String, MonthlyBudget> _webBudgets = {};
  static final Map<String, List<MonthlyExpense>> _webExpenses = {};
  
  // Getters
  MonthlyBudget? get currentBudget => _currentBudget;
  List<MonthlyExpense> get expenses => _expenses;
  Map<String, double> get expensesByCategory => _expensesByCategory;
  bool get isLoading => _isLoading;
  
  double get totalSpent {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
  
  double get remainingBudget {
    if (_currentBudget == null) return 0.0;
    return _currentBudget!.amount - totalSpent;
  }
  
  double get budgetPercentageUsed {
    if (_currentBudget == null || _currentBudget!.amount == 0) return 0.0;
    return (totalSpent / _currentBudget!.amount) * 100;
  }

  // Force stop loading if stuck
  void forceStopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Loading force stopped');
    }
  }

  // Calculate expenses by category
  void _calculateExpensesByCategory() {
    _expensesByCategory.clear();
    for (final expense in _expenses) {
      _expensesByCategory[expense.category] = 
          (_expensesByCategory[expense.category] ?? 0.0) + expense.amount;
    }
  }

  // Load data for specific month and year
  Future<void> loadMonthlyData(int month, int year) async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Loading monthly data for $month/$year');
      
      // Add timeout to prevent hanging
      await Future.any([
        _loadDataWithTimeout(month, year),
        Future.delayed(const Duration(seconds: 5), () => throw TimeoutException('Database timeout')),
      ]);
      
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
      // Initialize with empty data if database fails
      _currentBudget = null;
      _expenses = [];
      _expensesByCategory = {};
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('Monthly data loading completed');
    }
  }

  Future<void> _loadDataWithTimeout(int month, int year) async {
    try {
      // For web, use in-memory storage
      if (kIsWeb) {
        debugPrint('Web platform detected - using in-memory storage');
        final key = '$year-$month';
        _currentBudget = _webBudgets[key];
        _expenses = _webExpenses[key] ?? [];
        _calculateExpensesByCategory();
        return;
      }
      
      // Load budget
      _currentBudget = await _databaseHelper.getMonthlyBudget(month, year);
      debugPrint('Budget loaded: ${_currentBudget?.amount}');
      
      // Load expenses
      _expenses = await _databaseHelper.getMonthlyExpenses(month, year);
      debugPrint('Expenses loaded: ${_expenses.length} items');
      
      // Load expenses by category
      _expensesByCategory = await _databaseHelper.getMonthlyExpensesByCategory(month, year);
      debugPrint('Categories loaded: ${_expensesByCategory.keys.length} categories');
    } catch (e) {
      debugPrint('Database operation failed: $e');
      // Initialize with empty data
      _currentBudget = null;
      _expenses = [];
      _expensesByCategory = {};
    }
  }

  // Set or update monthly budget
  Future<bool> setBudget(double amount, int month, int year) async {
    try {
      final budget = MonthlyBudget(
        id: _currentBudget?.id ?? DateTime.now().millisecondsSinceEpoch,
        amount: amount,
        month: month,
        year: year,
        createdAt: _currentBudget?.createdAt ?? DateTime.now(),
      );
      
      if (kIsWeb) {
        // Use in-memory storage for web
        final key = '$year-$month';
        _webBudgets[key] = budget;
        _currentBudget = budget;
      } else {
        // Use database for mobile
        if (_currentBudget == null) {
          final id = await _databaseHelper.insertMonthlyBudget(budget);
          _currentBudget = MonthlyBudget(
            id: id,
            amount: amount,
            month: month,
            year: year,
            createdAt: DateTime.now(),
          );
        } else {
          await _databaseHelper.updateMonthlyBudget(budget);
          _currentBudget = budget;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting budget: $e');
      return false;
    }
  }

  // Add new expense
  Future<bool> addExpense(String title, String category, double amount, DateTime date, {String? description}) async {
    try {
      final expense = MonthlyExpense(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        category: category,
        amount: amount,
        date: date,
        description: description,
      );
      
      if (kIsWeb) {
        // Use in-memory storage for web
        final key = '${date.year}-${date.month}';
        _webExpenses[key] = _webExpenses[key] ?? [];
        _webExpenses[key]!.insert(0, expense);
        _expenses.insert(0, expense);
      } else {
        // Use database for mobile
        final id = await _databaseHelper.insertMonthlyExpense(expense);
        final newExpense = MonthlyExpense(
          id: id,
          title: title,
          category: category,
          amount: amount,
          date: date,
          description: description,
        );
        _expenses.insert(0, newExpense);
      }
      
      // Update category totals
      _expensesByCategory[category] = (_expensesByCategory[category] ?? 0.0) + amount;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(MonthlyExpense expense) async {
    try {
      await _databaseHelper.updateMonthlyExpense(expense);
      
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
      debugPrint('Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(int expenseId) async {
    try {
      await _databaseHelper.deleteMonthlyExpense(expenseId);
      
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
      debugPrint('Error deleting expense: $e');
      return false;
    }
  }

  // Get expenses for a specific category
  List<MonthlyExpense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Clear all data (for testing or reset)
  void clearData() {
    _currentBudget = null;
    _expenses.clear();
    _expensesByCategory.clear();
    notifyListeners();
  }
}