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
      try {
        // Change the default factory for web
        databaseFactory = databaseFactoryFfiWeb;
      } catch (e) {
        debugPrint('Web database initialization error: $e');
        // Fallback to in-memory database for web if FFI fails
      }
    }

    String path;
    if (kIsWeb) {
      // For web, use a simple name
      path = AppConstants.databaseName;
    } else {
      // For mobile, use the standard path
      path = join(await getDatabasesPath(), AppConstants.databaseName);
    }
    
    try {
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Database initialization error: $e');
      // For web, try with in-memory database as fallback
      if (kIsWeb) {
        return await openDatabase(
          ':memory:',
          version: AppConstants.databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      }
      rethrow;
    }
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

    // Create Trips table
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        destination TEXT NOT NULL,
        budget REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Travel Expenses table
    await db.execute('''
      CREATE TABLE travel_expenses (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id)
      )
    ''');

    // Create Savings Goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        target_amount REAL NOT NULL,
        target_date TEXT NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Savings Records table
    await db.execute('''
      CREATE TABLE savings_records (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT DEFAULT '',
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES savings_goals (id)
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

  // Continue in the next part due to length...
}

// Extension to add more methods
extension DatabaseHelperExtension on DatabaseHelper {
  // SPECIAL BUDGET OPERATIONS
  Future<int> insertSpecialBudget(SpecialBudget budget) async {
    final db = await database;
    return await db.insert(AppConstants.specialBudgetTable, budget.toMap());
  }

  Future<SpecialBudget?> getSpecialBudget(int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.specialBudgetTable,
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    if (maps.isNotEmpty) {
      return SpecialBudget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSpecialBudget(SpecialBudget budget) async {
    final db = await database;
    return await db.update(
      AppConstants.specialBudgetTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // SPECIAL ITEMS OPERATIONS
  Future<int> insertSpecialItem(SpecialItem item) async {
    final db = await database;
    return await db.insert(AppConstants.specialItemsTable, item.toMap());
  }

  Future<List<SpecialItem>> getSpecialItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.specialItemsTable,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SpecialItem.fromMap(maps[i]);
    });
  }

  Future<double> getTotalPurchasedItemsCost() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(estimated_cost) as total FROM ${AppConstants.specialItemsTable}
      WHERE is_purchased = 1
    ''');
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateSpecialItem(SpecialItem item) async {
    final db = await database;
    return await db.update(
      AppConstants.specialItemsTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteSpecialItem(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.specialItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}