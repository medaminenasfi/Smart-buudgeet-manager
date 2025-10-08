import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/special_purchase_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';
import '../models/special_purchase.dart';

class SpecialPurchasesScreen extends StatefulWidget {
  const SpecialPurchasesScreen({super.key});

  @override
  State<SpecialPurchasesScreen> createState() => _SpecialPurchasesScreenState();
}

class _SpecialPurchasesScreenState extends State<SpecialPurchasesScreen> {
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load data after the build is complete to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      debugPrint('SpecialPurchasesScreen: Starting data load for ${_currentDate.month}/${_currentDate.year}');
      final provider = Provider.of<SpecialPurchaseProvider>(context, listen: false);
      await provider.loadSpecialPurchaseData(_currentDate.month, _currentDate.year);
      debugPrint('SpecialPurchasesScreen: Data load completed');
    } catch (e) {
      debugPrint('SpecialPurchasesScreen: Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Special Purchases',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: Consumer<SpecialPurchaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading ${DateFormat('MMMM yyyy').format(_currentDate)} data...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBudgetOverview(provider),
                  const SizedBox(height: 24),
                  _buildItemsSection(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppConstants.specialColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetOverview(SpecialPurchaseProvider provider) {
    final monthYear = DateFormat('MMMM yyyy').format(_currentDate);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.specialColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showSetBudgetDialog(context, provider),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.currentBudget == null)
              _buildNoBudgetState()
            else
              _buildBudgetDetails(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBudgetState() {
    return Column(
      children: [
        const Icon(
          Icons.shopping_cart_outlined,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'No special purchases budget set',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set a budget for your special purchases and create a wishlist of items you want to buy',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showSetBudgetDialog(context, null),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.specialColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Set Special Purchases Budget'),
        ),
      ],
    );
  }

  Widget _buildBudgetDetails(SpecialPurchaseProvider provider) {
    final budget = provider.currentBudget!.amount;
    final spent = provider.totalSpent;
    final pending = provider.totalPendingCost;
    final remaining = provider.remainingBudget;
    final percentage = provider.budgetPercentageUsed;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBudgetItem('Budget', budget, AppConstants.specialColor),
            ),
            Expanded(
              child: _buildBudgetItem('Spent', spent, Colors.red),
            ),
            Expanded(
              child: _buildBudgetItem(
                'Remaining', 
                remaining, 
                remaining >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBudgetItem('Wishlist Total', pending, Colors.orange),
            ),
            Expanded(
              child: _buildBudgetItem('Items', provider.items.length.toDouble(), Colors.blue),
            ),
            Expanded(
              child: _buildBudgetItem('Purchased', provider.purchasedItems.length.toDouble(), Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage > 100 ? Colors.red : AppConstants.specialColor,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}% of budget used',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: percentage > 100 ? Colors.red : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (spent == 0.0 && provider.items.isEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.specialColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.specialColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppConstants.specialColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Start adding items to your wishlist that you want to purchase',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.specialColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label == 'Items' || label == 'Purchased' 
              ? amount.toInt().toString()
              : '${amount.toStringAsFixed(2)} ${AppConstants.currency}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(SpecialPurchaseProvider provider) {
    if (provider.items.isEmpty) {
      return _buildEmptyItemsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Wishlist',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: AppConstants.specialColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppConstants.specialColor,
                tabs: [
                  Tab(text: 'Wishlist (${provider.pendingItems.length})'),
                  Tab(text: 'Purchased (${provider.purchasedItems.length})'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    _buildItemsList(provider.pendingItems, false),
                    _buildItemsList(provider.purchasedItems, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<SpecialItem> items, bool isPurchased) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPurchased ? Icons.shopping_bag_outlined : Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isPurchased ? 'No purchased items yet' : 'No items in wishlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (!isPurchased) ...[
              const SizedBox(height: 8),
              Text(
                'Add items you want to purchase',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPurchased 
                  ? Colors.green.withOpacity(0.2) 
                  : AppConstants.specialColor.withOpacity(0.2),
              child: Icon(
                isPurchased ? Icons.shopping_bag : Icons.favorite,
                color: isPurchased ? Colors.green : AppConstants.specialColor,
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: isPurchased ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description != null && item.description!.isNotEmpty)
                  Text(item.description!),
                if (isPurchased && item.purchaseDate != null)
                  Text(
                    'Purchased: ${DateFormat('MMM dd, yyyy').format(item.purchaseDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.estimatedCost.toStringAsFixed(2)} ${AppConstants.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!isPurchased)
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.green),
                    onPressed: () => _purchaseItem(context, item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            onTap: () => _showItemDetails(context, item),
          ),
        );
      },
    );
  }

  Widget _buildEmptyItemsState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No items in your wishlist',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add special items you want to purchase and track your spending',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.specialColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, SpecialPurchaseProvider? provider) {
    final TextEditingController budgetController = TextEditingController();
    if (provider?.currentBudget != null) {
      budgetController.text = provider!.currentBudget!.amount.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(provider?.currentBudget == null ? 'Set Special Purchases Budget' : 'Update Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '${AppConstants.currency} ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Set your budget for special purchases like electronics, gadgets, or other items you want to buy.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(budgetController.text);
                if (amount != null && amount > 0) {
                  final provider = Provider.of<SpecialPurchaseProvider>(context, listen: false);
                  final success = await provider.setBudget(amount, _currentDate.month, _currentDate.year);
                  if (success && mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget set successfully!')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.specialColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item to Wishlist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Estimated Cost',
                    prefixText: '${AppConstants.currency} ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final cost = double.tryParse(costController.text);
                
                if (name.isNotEmpty && cost != null && cost > 0) {
                  final provider = Provider.of<SpecialPurchaseProvider>(context, listen: false);
                  final success = await provider.addItem(
                    name,
                    cost,
                    description: descriptionController.text.trim().isNotEmpty 
                        ? descriptionController.text.trim() 
                        : null,
                  );
                  
                  if (success && mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item added to wishlist!')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.specialColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  void _purchaseItem(BuildContext context, SpecialItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Purchased'),
          content: Text('Mark "${item.name}" as purchased for ${item.estimatedCost.toStringAsFixed(2)} ${AppConstants.currency}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<SpecialPurchaseProvider>(context, listen: false);
                final success = await provider.purchaseItem(item.id!);
                
                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item marked as purchased!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Purchase'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, SpecialItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cost: ${item.estimatedCost.toStringAsFixed(2)} ${AppConstants.currency}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Status: ${item.isPurchased ? "Purchased" : "In Wishlist"}'),
              if (item.purchaseDate != null) ...[
                const SizedBox(height: 8),
                Text('Purchase Date: ${DateFormat('MMM dd, yyyy').format(item.purchaseDate!)}'),
              ],
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.description!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (!item.isPurchased)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _purchaseItem(context, item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Purchase'),
              ),
          ],
        );
      },
    );
  }
}