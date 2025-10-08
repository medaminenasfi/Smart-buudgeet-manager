import 'database_helper.dart';
import '../models/models.dart';
import '../utils/constants.dart';

// Extension for Travel and Savings operations
extension DatabaseHelperTravelSavings on DatabaseHelper {
  // TRAVEL BUDGET OPERATIONS
  Future<int> insertTravelBudget(TravelBudget budget) async {
    final db = await database;
    return await db.insert(AppConstants.travelBudgetTable, budget.toMap());
  }

  Future<List<TravelBudget>> getTravelBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.travelBudgetTable,
      orderBy: 'start_date DESC',
    );

    return List.generate(maps.length, (i) {
      return TravelBudget.fromMap(maps[i]);
    });
  }

  Future<TravelBudget?> getTravelBudgetById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.travelBudgetTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TravelBudget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTravelBudget(TravelBudget budget) async {
    final db = await database;
    return await db.update(
      AppConstants.travelBudgetTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteTravelBudget(int id) async {
    final db = await database;
    // First delete all related expenses
    await db.delete(
      AppConstants.travelExpensesTable,
      where: 'travel_budget_id = ?',
      whereArgs: [id],
    );
    
    // Then delete the budget
    return await db.delete(
      AppConstants.travelBudgetTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // TRAVEL EXPENSES OPERATIONS
  Future<int> insertTravelExpense(TravelExpense expense) async {
    final db = await database;
    return await db.insert(AppConstants.travelExpensesTable, expense.toMap());
  }

  Future<List<TravelExpense>> getTravelExpenses(int travelBudgetId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.travelExpensesTable,
      where: 'travel_budget_id = ?',
      whereArgs: [travelBudgetId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return TravelExpense.fromMap(maps[i]);
    });
  }

  Future<double> getTotalTravelExpenses(int travelBudgetId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM ${AppConstants.travelExpensesTable}
      WHERE travel_budget_id = ?
    ''', [travelBudgetId]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getTravelExpensesByCategory(int travelBudgetId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM ${AppConstants.travelExpensesTable}
      WHERE travel_budget_id = ?
      GROUP BY category
    ''', [travelBudgetId]);
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  Future<int> updateTravelExpense(TravelExpense expense) async {
    final db = await database;
    return await db.update(
      AppConstants.travelExpensesTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteTravelExpense(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.travelExpensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SAVINGS GOAL OPERATIONS
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.insert(AppConstants.savingsGoalTable, goal.toMap());
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.savingsGoalTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavingsGoal.fromMap(maps[i]);
    });
  }

  Future<SavingsGoal?> getSavingsGoalById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.savingsGoalTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavingsGoal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.update(
      AppConstants.savingsGoalTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    // First delete all related records
    await db.delete(
      AppConstants.savingsRecordsTable,
      where: 'savings_goal_id = ?',
      whereArgs: [id],
    );
    
    // Then delete the goal
    return await db.delete(
      AppConstants.savingsGoalTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SAVINGS RECORDS OPERATIONS
  Future<int> insertSavingsRecord(SavingsRecord record) async {
    final db = await database;
    return await db.insert(AppConstants.savingsRecordsTable, record.toMap());
  }

  Future<List<SavingsRecord>> getSavingsRecords(int savingsGoalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.savingsRecordsTable,
      where: 'savings_goal_id = ?',
      whereArgs: [savingsGoalId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return SavingsRecord.fromMap(maps[i]);
    });
  }

  Future<double> getTotalSavings(int savingsGoalId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM ${AppConstants.savingsRecordsTable}
      WHERE savings_goal_id = ?
    ''', [savingsGoalId]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateSavingsRecord(SavingsRecord record) async {
    final db = await database;
    return await db.update(
      AppConstants.savingsRecordsTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteSavingsRecord(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.savingsRecordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UTILITY OPERATIONS
  Future<Map<String, double>> getMonthlyExpensesByCategory(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM ${AppConstants.monthlyExpensesTable}
      WHERE date LIKE ?
      GROUP BY category
    ''', ['$year-${month.toString().padLeft(2, '0')}%']);
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}