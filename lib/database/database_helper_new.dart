import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

// Web support
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/models.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize web database if running on web
    if (kIsWeb) {
      // Change the default factory for web
      databaseFactory = databaseFactoryFfiWeb;
    }

    String path;
    if (kIsWeb) {
      // For web, use a simple name
      path = AppConstants.databaseName;
    } else {
      // For mobile, use the standard path
      path = join(await getDatabasesPath(), AppConstants.databaseName);
    }
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Monthly Budget table
    await db.execute('''
      CREATE TABLE ${AppConstants.monthlyBudgetTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Monthly Expenses table
    await db.execute('''
      CREATE TABLE ${AppConstants.monthlyExpensesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create Special Budget table
    await db.execute('''
      CREATE TABLE ${AppConstants.specialBudgetTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Special Items table
    await db.execute('''
      CREATE TABLE ${AppConstants.specialItemsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        estimated_cost REAL NOT NULL,
        is_purchased INTEGER DEFAULT 0,
        purchase_date TEXT,
        created_at TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create Travel Budget table
    await db.execute('''
      CREATE TABLE ${AppConstants.travelBudgetTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        destination TEXT NOT NULL,
        amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Travel Expenses table
    await db.execute('''
      CREATE TABLE ${AppConstants.travelExpensesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        travel_budget_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (travel_budget_id) REFERENCES ${AppConstants.travelBudgetTable} (id)
      )
    ''');

    // Create Savings Goal table
    await db.execute('''
      CREATE TABLE ${AppConstants.savingsGoalTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        target_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create Savings Records table
    await db.execute('''
      CREATE TABLE ${AppConstants.savingsRecordsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        savings_goal_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (savings_goal_id) REFERENCES ${AppConstants.savingsGoalTable} (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed in future versions
  }

  // MONTHLY BUDGET OPERATIONS
  Future<int> insertMonthlyBudget(MonthlyBudget budget) async {
    final db = await database;
    return await db.insert(AppConstants.monthlyBudgetTable, budget.toMap());
  }

  Future<MonthlyBudget?> getMonthlyBudget(int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.monthlyBudgetTable,
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    if (maps.isNotEmpty) {
      return MonthlyBudget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMonthlyBudget(MonthlyBudget budget) async {
    final db = await database;
    return await db.update(
      AppConstants.monthlyBudgetTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // MONTHLY EXPENSES OPERATIONS
  Future<int> insertMonthlyExpense(MonthlyExpense expense) async {
    final db = await database;
    return await db.insert(AppConstants.monthlyExpensesTable, expense.toMap());
  }

  Future<List<MonthlyExpense>> getMonthlyExpenses(int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.monthlyExpensesTable,
      where: 'date LIKE ?',
      whereArgs: ['$year-${month.toString().padLeft(2, '0')}%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return MonthlyExpense.fromMap(maps[i]);
    });
  }

  Future<double> getTotalMonthlyExpenses(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM ${AppConstants.monthlyExpensesTable}
      WHERE date LIKE ?
    ''', ['$year-${month.toString().padLeft(2, '0')}%']);
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateMonthlyExpense(MonthlyExpense expense) async {
    final db = await database;
    return await db.update(
      AppConstants.monthlyExpensesTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteMonthlyExpense(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.monthlyExpensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Continue in the extensions file for other operations...
}