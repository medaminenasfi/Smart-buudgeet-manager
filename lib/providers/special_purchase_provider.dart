import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class SpecialPurchaseProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  SpecialBudget? _currentBudget;
  List<SpecialItem> _items = [];
  bool _isLoading = false;
  
  // Getters
  SpecialBudget? get currentBudget => _currentBudget;
  List<SpecialItem> get items => _items;
  bool get isLoading => _isLoading;
  
  List<SpecialItem> get pendingItems => _items.where((item) => !item.isPurchased).toList();
  List<SpecialItem> get purchasedItems => _items.where((item) => item.isPurchased).toList();
  
  double get totalSpent {
    return _items
        .where((item) => item.isPurchased)
        .fold(0.0, (sum, item) => sum + item.estimatedCost);
  }
  
  double get totalPendingCost {
    return pendingItems.fold(0.0, (sum, item) => sum + item.estimatedCost);
  }
  
  double get remainingBudget {
    if (_currentBudget == null) return 0.0;
    return _currentBudget!.amount - totalSpent;
  }
  
  double get budgetPercentageUsed {
    if (_currentBudget == null || _currentBudget!.amount == 0) return 0.0;
    return (totalSpent / _currentBudget!.amount) * 100;
  }

  // Load data for specific month and year
  Future<void> loadSpecialPurchaseData(int month, int year) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load budget
      _currentBudget = await _databaseHelper.getSpecialBudget(month, year);
      
      // Load all items (not filtered by date as they are ongoing)
      _items = await _databaseHelper.getSpecialItems();
      
    } catch (e) {
      debugPrint('Error loading special purchase data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set or update special budget
  Future<bool> setBudget(double amount, int month, int year) async {
    try {
      if (_currentBudget == null) {
        // Create new budget
        final budget = SpecialBudget(
          amount: amount,
          month: month,
          year: year,
          createdAt: DateTime.now(),
        );
        
        final id = await _databaseHelper.insertSpecialBudget(budget);
        _currentBudget = SpecialBudget(
          id: id,
          amount: amount,
          month: month,
          year: year,
          createdAt: DateTime.now(),
        );
      } else {
        // Update existing budget
        final updatedBudget = SpecialBudget(
          id: _currentBudget!.id,
          amount: amount,
          month: month,
          year: year,
          createdAt: _currentBudget!.createdAt,
        );
        
        await _databaseHelper.updateSpecialBudget(updatedBudget);
        _currentBudget = updatedBudget;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting special budget: $e');
      return false;
    }
  }

  // Add new item to wishlist
  Future<bool> addItem(String name, double estimatedCost, {String? description}) async {
    try {
      final item = SpecialItem(
        name: name,
        estimatedCost: estimatedCost,
        createdAt: DateTime.now(),
        description: description,
      );
      
      final id = await _databaseHelper.insertSpecialItem(item);
      
      final newItem = SpecialItem(
        id: id,
        name: name,
        estimatedCost: estimatedCost,
        createdAt: DateTime.now(),
        description: description,
      );
      
      _items.insert(0, newItem);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding special item: $e');
      return false;
    }
  }

  // Mark item as purchased
  Future<bool> markAsPurchased(int itemId) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) return false;
      
      final item = _items[itemIndex];
      final updatedItem = SpecialItem(
        id: item.id,
        name: item.name,
        estimatedCost: item.estimatedCost,
        isPurchased: true,
        purchaseDate: DateTime.now(),
        createdAt: item.createdAt,
        description: item.description,
      );
      
      await _databaseHelper.updateSpecialItem(updatedItem);
      _items[itemIndex] = updatedItem;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error marking item as purchased: $e');
      return false;
    }
  }

  // Mark item as not purchased (undo purchase)
  Future<bool> markAsNotPurchased(int itemId) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) return false;
      
      final item = _items[itemIndex];
      final updatedItem = SpecialItem(
        id: item.id,
        name: item.name,
        estimatedCost: item.estimatedCost,
        isPurchased: false,
        purchaseDate: null,
        createdAt: item.createdAt,
        description: item.description,
      );
      
      await _databaseHelper.updateSpecialItem(updatedItem);
      _items[itemIndex] = updatedItem;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error unmarking item as purchased: $e');
      return false;
    }
  }

  // Update item
  Future<bool> updateItem(SpecialItem item) async {
    try {
      await _databaseHelper.updateSpecialItem(item);
      
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating special item: $e');
      return false;
    }
  }

  // Delete item
  Future<bool> deleteItem(int itemId) async {
    try {
      await _databaseHelper.deleteSpecialItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting special item: $e');
      return false;
    }
  }

  // Check if item can be afforded with remaining budget
  bool canAfford(double itemCost) {
    return remainingBudget >= itemCost;
  }

  // Get affordable items from pending list
  List<SpecialItem> getAffordableItems() {
    return pendingItems.where((item) => canAfford(item.estimatedCost)).toList();
  }

  // Clear all data
  void clearData() {
    _currentBudget = null;
    _items.clear();
    notifyListeners();
  }
}