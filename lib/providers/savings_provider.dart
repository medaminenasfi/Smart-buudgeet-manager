import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../database/database_extensions.dart';

class SavingsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<SavingsGoal> _savingsGoals = [];
  SavingsGoal? _selectedGoal;
  List<SavingsRecord> _savingsRecords = [];
  bool _isLoading = false;
  
  // Getters
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  SavingsGoal? get selectedGoal => _selectedGoal;
  List<SavingsRecord> get savingsRecords => _savingsRecords;
  bool get isLoading => _isLoading;
  
  double get totalSaved {
    return _savingsRecords.fold(0.0, (sum, record) => sum + record.amount);
  }
  
  double get remainingToSave {
    if (_selectedGoal == null) return 0.0;
    return _selectedGoal!.targetAmount - totalSaved;
  }
  
  double get savingsPercentage {
    if (_selectedGoal == null || _selectedGoal!.targetAmount == 0) return 0.0;
    return (totalSaved / _selectedGoal!.targetAmount) * 100;
  }
  
  bool get isGoalReached {
    return savingsPercentage >= 100;
  }
  
  int get daysUntilTarget {
    if (_selectedGoal == null) return 0;
    return _selectedGoal!.targetDate.difference(DateTime.now()).inDays;
  }
  
  double get dailySavingsNeeded {
    if (_selectedGoal == null || daysUntilTarget <= 0) return 0.0;
    return remainingToSave / daysUntilTarget;
  }

  // Load all savings goals
  Future<void> loadSavingsGoals() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _savingsGoals = await _databaseHelper.getSavingsGoals();
    } catch (e) {
      debugPrint('Error loading savings goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a specific savings goal and load its records
  Future<void> selectSavingsGoal(int goalId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _selectedGoal = await _databaseHelper.getSavingsGoalById(goalId);
      _savingsRecords = await _databaseHelper.getSavingsRecords(goalId);
    } catch (e) {
      debugPrint('Error selecting savings goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new savings goal
  Future<bool> createSavingsGoal(String goalName, double targetAmount, DateTime targetDate, {String? description}) async {
    try {
      final goal = SavingsGoal(
        goalName: goalName,
        targetAmount: targetAmount,
        targetDate: targetDate,
        createdAt: DateTime.now(),
        description: description,
      );
      
      final id = await _databaseHelper.insertSavingsGoal(goal);
      
      final newGoal = SavingsGoal(
        id: id,
        goalName: goalName,
        targetAmount: targetAmount,
        targetDate: targetDate,
        createdAt: DateTime.now(),
        description: description,
      );
      
      _savingsGoals.insert(0, newGoal);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating savings goal: $e');
      return false;
    }
  }

  // Update savings goal
  Future<bool> updateSavingsGoal(SavingsGoal goal) async {
    try {
      await _databaseHelper.updateSavingsGoal(goal);
      
      final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _savingsGoals[index] = goal;
        if (_selectedGoal?.id == goal.id) {
          _selectedGoal = goal;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating savings goal: $e');
      return false;
    }
  }

  // Delete savings goal
  Future<bool> deleteSavingsGoal(int goalId) async {
    try {
      await _databaseHelper.deleteSavingsGoal(goalId);
      
      _savingsGoals.removeWhere((goal) => goal.id == goalId);
      
      if (_selectedGoal?.id == goalId) {
        _selectedGoal = null;
        _savingsRecords.clear();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting savings goal: $e');
      return false;
    }
  }

  // Add savings record
  Future<bool> addSavingsRecord(double amount, DateTime date, {String? description}) async {
    if (_selectedGoal == null) return false;
    
    try {
      final record = SavingsRecord(
        savingsGoalId: _selectedGoal!.id!,
        amount: amount,
        date: date,
        description: description,
      );
      
      final id = await _databaseHelper.insertSavingsRecord(record);
      
      final newRecord = SavingsRecord(
        id: id,
        savingsGoalId: _selectedGoal!.id!,
        amount: amount,
        date: date,
        description: description,
      );
      
      _savingsRecords.insert(0, newRecord);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding savings record: $e');
      return false;
    }
  }

  // Update savings record
  Future<bool> updateSavingsRecord(SavingsRecord record) async {
    try {
      await _databaseHelper.updateSavingsRecord(record);
      
      final index = _savingsRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _savingsRecords[index] = record;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating savings record: $e');
      return false;
    }
  }

  // Delete savings record
  Future<bool> deleteSavingsRecord(int recordId) async {
    try {
      await _databaseHelper.deleteSavingsRecord(recordId);
      _savingsRecords.removeWhere((record) => record.id == recordId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting savings record: $e');
      return false;
    }
  }

  // Get recent savings records (last 10)
  List<SavingsRecord> getRecentRecords() {
    return _savingsRecords.take(10).toList();
  }

  // Get monthly savings total
  double getMonthlySavings(int month, int year) {
    return _savingsRecords
        .where((record) => 
            record.date.month == month && record.date.year == year)
        .fold(0.0, (sum, record) => sum + record.amount);
  }

  // Get savings records for a specific month
  List<SavingsRecord> getMonthlySavingsRecords(int month, int year) {
    return _savingsRecords
        .where((record) => 
            record.date.month == month && record.date.year == year)
        .toList();
  }

  // Clear selected goal data
  void clearSelectedGoal() {
    _selectedGoal = null;
    _savingsRecords.clear();
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _savingsGoals.clear();
    _selectedGoal = null;
    _savingsRecords.clear();
    notifyListeners();
  }
}