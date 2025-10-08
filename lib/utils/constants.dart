import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Smart Budget Manager';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'budget_manager.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String monthlyBudgetTable = 'monthly_budget';
  static const String monthlyExpensesTable = 'monthly_expenses';
  static const String specialBudgetTable = 'special_budget';
  static const String specialItemsTable = 'special_items';
  static const String travelBudgetTable = 'travel_budget';
  static const String travelExpensesTable = 'travel_expenses';
  static const String savingsGoalTable = 'savings_goal';
  static const String savingsRecordsTable = 'savings_records';

  // Currency
  static const String currency = 'TND';

  // Expense Categories
  static const List<String> monthlyExpenseCategories = [
    'Food & Groceries',
    'Transportation',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Shopping',
    'Other'
  ];

  static const List<String> travelExpenseCategories = [
    'Accommodation',
    'Transportation',
    'Food & Dining',
    'Activities',
    'Shopping',
    'Emergency',
    'Other'
  ];

  // Colors
  static const Color monthlyColor = Colors.orange;
  static const Color specialColor = Colors.purple;
  static const Color travelColor = Colors.blue;
  static const Color savingsColor = Colors.green;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String monthYearFormat = 'MMMM yyyy';
}