import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/savings_models.dart';

class SavingsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<SavingsGoal> _goals = [];
  List<SavingsRecord> _records = [];
  SavingsGoal? _selectedGoal;
  bool _isLoading = false;

  // Web storage fallback
  final Map<String, SavingsGoal> _webGoals = {};
  final Map<String, SavingsRecord> _webRecords = {};

  List<SavingsGoal> get goals => _goals;
  List<SavingsRecord> get records => _records;
  SavingsGoal? get selectedGoal => _selectedGoal;
  bool get isLoading => _isLoading;

  List<SavingsGoal> get activeGoals => 
      _goals.where((goal) => goal.status == SavingsGoalStatus.active).toList();

  List<SavingsGoal> get completedGoals => 
      _goals.where((goal) => goal.status == SavingsGoalStatus.completed).toList();

  List<SavingsGoal> get overdueGoals => 
      _goals.where((goal) => goal.isOverdue).toList();

  double get totalTargetAmount => 
      activeGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  double get totalSavedAmount {
    double total = 0.0;
    for (final goal in activeGoals) {
      total += getCurrentAmount(goal.id);
    }
    return total;
  }

  Future<void> loadSavingsData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Loading savings data');

      if (kIsWeb) {
        debugPrint('Web platform detected - using in-memory storage');
        
        // Load from web storage
        _goals = _webGoals.values.toList();
        _records = _webRecords.values.toList();
        
        // Set selected goal to first active goal if none selected
        if (_selectedGoal == null && activeGoals.isNotEmpty) {
          _selectedGoal = activeGoals.first;
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        
      } else {
        // Load from SQLite database
        final database = await _databaseHelper.database;
        
        // Load goals
        final goalsResult = await database.query('savings_goals');
        _goals = goalsResult.map((map) => SavingsGoal.fromMap(map)).toList();
        
        // Load records
        final recordsResult = await database.query('savings_records');
        _records = recordsResult.map((map) => SavingsRecord.fromMap(map)).toList();
        
        // Set selected goal to first active goal if none selected
        if (_selectedGoal == null && activeGoals.isNotEmpty) {
          _selectedGoal = activeGoals.first;
        }
      }

      // Sort goals by priority and creation date
      _goals.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      // Sort records by date (newest first)
      _records.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Goals loaded: ${_goals.length} goals');
      debugPrint('Records loaded: ${_records.length} records');
      debugPrint('Selected goal: ${_selectedGoal?.name ?? 'None'}');
      
    } catch (e) {
      debugPrint('Database operation failed: $e');
      // Initialize with empty data
      _goals = [];
      _records = [];
      _selectedGoal = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGoal(
    String name,
    String description,
    double targetAmount,
    DateTime targetDate,
    SavingsGoalCategory category,
    SavingsGoalPriority priority,
  ) async {
    final goalId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final goal = SavingsGoal(
      id: goalId,
      name: name,
      description: description,
      targetAmount: targetAmount,
      targetDate: targetDate,
      category: category,
      priority: priority,
      status: SavingsGoalStatus.active,
      createdAt: DateTime.now(),
    );

    try {
      if (kIsWeb) {
        _webGoals[goalId] = goal;
        _goals = _webGoals.values.toList();
        
        if (_selectedGoal == null) {
          _selectedGoal = goal;
        }
        
      } else {
        final database = await _databaseHelper.database;
        await database.insert('savings_goals', goal.toMap());
        _goals.add(goal);
        
        if (_selectedGoal == null) {
          _selectedGoal = goal;
        }
      }

      // Re-sort goals
      _goals.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      debugPrint('Goal created: ${goal.name}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error creating goal: $e');
    }
  }

  Future<void> addSavingsRecord(
    String goalId,
    double amount,
    String description,
    DateTime date,
  ) async {
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final record = SavingsRecord(
      id: recordId,
      goalId: goalId,
      amount: amount,
      description: description,
      date: date,
      createdAt: DateTime.now(),
    );

    try {
      if (kIsWeb) {
        _webRecords[recordId] = record;
        _records = _webRecords.values.toList();
        
      } else {
        final database = await _databaseHelper.database;
        await database.insert('savings_records', record.toMap());
        _records.add(record);
      }

      // Sort records by date (newest first)
      _records.sort((a, b) => b.date.compareTo(a.date));

      // Check if goal is completed
      final currentAmount = getCurrentAmount(goalId);
      final goal = _goals.firstWhere((g) => g.id == goalId);
      
      if (currentAmount >= goal.targetAmount && goal.status == SavingsGoalStatus.active) {
        await completeGoal(goalId);
      }

      debugPrint('Savings record added: \$${amount.toStringAsFixed(2)} to $goalId');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error adding savings record: $e');
    }
  }

  Future<void> completeGoal(String goalId) async {
    try {
      if (kIsWeb) {
        final existingGoal = _webGoals[goalId];
        if (existingGoal != null) {
          _webGoals[goalId] = existingGoal.copyWith(status: SavingsGoalStatus.completed);
          _goals = _webGoals.values.toList();
          
          if (_selectedGoal?.id == goalId) {
            _selectedGoal = activeGoals.isNotEmpty ? activeGoals.first : null;
          }
        }
        
      } else {
        final database = await _databaseHelper.database;
        
        await database.update(
          'savings_goals',
          {'status': SavingsGoalStatus.completed.name},
          where: 'id = ?',
          whereArgs: [goalId],
        );
        
        final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
        if (goalIndex != -1) {
          _goals[goalIndex] = _goals[goalIndex].copyWith(status: SavingsGoalStatus.completed);
          
          if (_selectedGoal?.id == goalId) {
            _selectedGoal = activeGoals.isNotEmpty ? activeGoals.first : null;
          }
        }
      }

      debugPrint('Goal completed: $goalId');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error completing goal: $e');
    }
  }

  void selectGoal(String goalId) {
    _selectedGoal = _goals.firstWhere(
      (goal) => goal.id == goalId,
      orElse: () => _goals.isNotEmpty ? _goals.first : throw Exception('No goals found'),
    );
    notifyListeners();
  }

  double getCurrentAmount(String goalId) {
    return _records
        .where((record) => record.goalId == goalId)
        .fold(0.0, (sum, record) => sum + record.amount);
  }

  List<SavingsRecord> getRecordsForGoal(String goalId) {
    return _records.where((record) => record.goalId == goalId).toList();
  }

  SavingsGoalWithProgress getGoalWithProgress(String goalId) {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    final currentAmount = getCurrentAmount(goalId);
    final records = getRecordsForGoal(goalId);
    
    return SavingsGoalWithProgress(
      goal: goal,
      currentAmount: currentAmount,
      records: records,
    );
  }

  List<SavingsGoalWithProgress> get goalsWithProgress {
    return _goals.map((goal) => getGoalWithProgress(goal.id)).toList();
  }

  List<SavingsGoalWithProgress> get activeGoalsWithProgress {
    return activeGoals.map((goal) => getGoalWithProgress(goal.id)).toList();
  }

  Map<SavingsGoalCategory, double> getCategorySavings() {
    final categorySavings = <SavingsGoalCategory, double>{};
    
    for (final category in SavingsGoalCategory.values) {
      categorySavings[category] = 0.0;
    }
    
    for (final goal in activeGoals) {
      final currentAmount = getCurrentAmount(goal.id);
      categorySavings[goal.category] = 
          (categorySavings[goal.category] ?? 0.0) + currentAmount;
    }
    
    return categorySavings;
  }
}