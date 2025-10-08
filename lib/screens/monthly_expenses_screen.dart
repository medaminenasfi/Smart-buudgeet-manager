import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/monthly_budget_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';
import '../models/monthly_budget.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen> {
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
      debugPrint('MonthlyExpensesScreen: Starting data load for ${_currentDate.month}/${_currentDate.year}');
      final provider = Provider.of<MonthlyBudgetProvider>(context, listen: false);
      await provider.loadMonthlyData(_currentDate.month, _currentDate.year);
      debugPrint('MonthlyExpensesScreen: Data load completed');
    } catch (e) {
      debugPrint('MonthlyExpensesScreen: Error loading data: $e');
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
        title: 'Monthly Expenses',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExpenseDialog(context),
          ),
        ],
      ),
      body: Consumer<MonthlyBudgetProvider>(
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
                  _buildExpensesList(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: AppConstants.monthlyColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetOverview(MonthlyBudgetProvider provider) {
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
                    color: AppConstants.monthlyColor,
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
          Icons.account_balance_wallet_outlined,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'No budget set for this month',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your monthly budget first, then add your expenses as you spend money throughout the month',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showSetBudgetDialog(context, null),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.monthlyColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Set Monthly Budget'),
        ),
      ],
    );
  }

  Widget _buildBudgetDetails(MonthlyBudgetProvider provider) {
    final budget = provider.currentBudget!.amount;
    final spent = provider.totalSpent;
    final remaining = provider.remainingBudget;
    final percentage = provider.budgetPercentageUsed;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBudgetItem('Budget', budget, AppConstants.monthlyColor),
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
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage > 100 ? Colors.red : AppConstants.monthlyColor,
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
        if (spent == 0.0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.monthlyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.monthlyColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppConstants.monthlyColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Now add your expenses whenever you spend money',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.monthlyColor,
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
          '${amount.toStringAsFixed(2)} ${AppConstants.currency}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesList(MonthlyBudgetProvider provider) {
    if (provider.expenses.isEmpty) {
      return _buildEmptyExpensesState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Expenses',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.expenses.length,
          itemBuilder: (context, index) {
            final expense = provider.expenses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppConstants.monthlyColor.withOpacity(0.2),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: AppConstants.monthlyColor,
                  ),
                ),
                title: Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.category),
                    Text(
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${expense.amount.toStringAsFixed(2)} ${AppConstants.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () => _showExpenseDetails(context, expense),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyExpensesState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.receipt_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every time you spend money, add it here to track your budget',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddExpenseDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.monthlyColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & groceries':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'bills & utilities':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.medical_services;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  void _showSetBudgetDialog(BuildContext context, MonthlyBudgetProvider? provider) {
    final textController = TextEditingController();
    if (provider?.currentBudget != null) {
      textController.text = provider!.currentBudget!.amount.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Amount (${AppConstants.currency})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(textController.text);
              if (amount != null && amount > 0) {
                final monthlyProvider = Provider.of<MonthlyBudgetProvider>(context, listen: false);
                await monthlyProvider.setBudget(amount, _currentDate.month, _currentDate.year);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = AppConstants.monthlyExpenseCategories.first;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.monthlyExpenseCategories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (${AppConstants.currency})',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text);
                
                if (title.isNotEmpty && amount != null && amount > 0) {
                  final provider = Provider.of<MonthlyBudgetProvider>(context, listen: false);
                  await provider.addExpense(
                    title,
                    selectedCategory,
                    amount,
                    selectedDate,
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, MonthlyExpense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category', expense.category),
            _buildDetailRow('Amount', '${expense.amount.toStringAsFixed(2)} ${AppConstants.currency}'),
            _buildDetailRow('Date', DateFormat('MMMM dd, yyyy').format(expense.date)),
            if (expense.description != null)
              _buildDetailRow('Description', expense.description!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<MonthlyBudgetProvider>(context, listen: false);
              await provider.deleteExpense(expense.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}