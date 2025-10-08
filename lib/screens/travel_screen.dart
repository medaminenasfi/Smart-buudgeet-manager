import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/travel_provider.dart';
import '../models/travel_models.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelProvider>().loadTravelData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          'Travel Budget',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.flight_takeoff, color: Colors.white),
              text: 'Current Trip',
            ),
            Tab(
              icon: Icon(Icons.history, color: Colors.white),
              text: 'Trip History',
            ),
            Tab(
              icon: Icon(Icons.analytics, color: Colors.white),
              text: 'Analytics',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer<TravelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading travel data...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentTripTab(context, provider),
              _buildTripHistoryTab(context, provider),
              _buildAnalyticsTab(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTripTab(BuildContext context, TravelProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Trip Overview
          _buildCurrentTripCard(context, provider),
          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(context, provider),
          const SizedBox(height: 20),

          // Expense Categories
          _buildExpenseCategories(context, provider),
          const SizedBox(height: 20),

          // Recent Expenses
          _buildRecentExpenses(context, provider),
        ],
      ),
    );
  }

  Widget _buildCurrentTripCard(BuildContext context, TravelProvider provider) {
    final currentTrip = provider.currentTrip;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentTrip != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTrip.destination,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(currentTrip.startDate)} - ${_formatDate(currentTrip.endDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentTrip.status.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Budget Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${provider.totalSpent.toStringAsFixed(2)} / \$${currentTrip.budget.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: currentTrip.budget > 0 ? (provider.totalSpent / currentTrip.budget).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      provider.totalSpent > currentTrip.budget ? Colors.red : Colors.green,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining: \$${(currentTrip.budget - provider.totalSpent).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: provider.totalSpent > currentTrip.budget ? Colors.red.shade100 : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 64,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Active Trip',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new trip to start tracking your travel expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, TravelProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_location_alt,
            title: provider.currentTrip != null ? 'Edit Trip' : 'New Trip',
            color: Colors.blue,
            onTap: () => _showTripDialog(context, provider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_shopping_cart,
            title: 'Add Expense',
            color: Colors.green,
            onTap: provider.currentTrip != null 
              ? () => _showExpenseDialog(context, provider)
              : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.receipt_long,
            title: 'View Report',
            color: Colors.orange,
            onTap: provider.currentTrip != null 
              ? () => _showTripReport(context, provider)
              : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: onTap != null ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCategories(BuildContext context, TravelProvider provider) {
    if (provider.currentTrip == null) {
      return const SizedBox.shrink();
    }

    final categories = TravelExpenseCategory.values;
    final categorySpending = provider.getCategorySpending();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final spent = categorySpending[category] ?? 0.0;
            
            return _buildCategoryCard(category, spent);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(TravelExpenseCategory category, double spent) {
    final categoryInfo = _getCategoryInfo(category);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryInfo['icon'],
              size: 32,
              color: categoryInfo['color'],
            ),
            const SizedBox(height: 8),
            Text(
              categoryInfo['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${spent.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: categoryInfo['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(BuildContext context, TravelProvider provider) {
    if (provider.currentTrip == null || provider.expenses.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No expenses yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first travel expense to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recentExpenses = provider.expenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentExpenses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final expense = recentExpenses[index];
              final categoryInfo = _getCategoryInfo(expense.category);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (categoryInfo['color'] as Color).withOpacity(0.1),
                  child: Icon(
                    categoryInfo['icon'],
                    color: categoryInfo['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${categoryInfo['name']} • ${_formatDate(expense.date)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _showExpenseDetails(context, expense),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripHistoryTab(BuildContext context, TravelProvider provider) {
    final completedTrips = provider.trips.where((trip) => trip.status == TripStatus.completed).toList();

    if (completedTrips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Trip History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete some trips to see your travel history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedTrips.length,
      itemBuilder: (context, index) {
        final trip = completedTrips[index];
        final tripExpenses = provider.expenses.where((e) => e.tripId == trip.id).toList();
        final totalSpent = tripExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.flight_takeoff, color: Colors.blue),
            ),
            title: Text(
              trip.destination,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}'),
                const SizedBox(height: 4),
                Text(
                  'Spent: \$${totalSpent.toStringAsFixed(2)} / \$${trip.budget.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: totalSpent > trip.budget ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTripDetails(context, trip, tripExpenses),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, TravelProvider provider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Analytics Coming Soon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Travel analytics and insights will be available here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showTripDialog(BuildContext context, TravelProvider provider) {
    final trip = provider.currentTrip;
    final destinationController = TextEditingController(text: trip?.destination ?? '');
    final budgetController = TextEditingController(text: trip?.budget.toString() ?? '');
    DateTime startDate = trip?.startDate ?? DateTime.now();
    DateTime endDate = trip?.endDate ?? DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(trip != null ? 'Edit Trip' : 'New Trip'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                        child: Text('Start: ${_formatDate(startDate)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                        child: Text('End: ${_formatDate(endDate)}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (trip != null)
              TextButton(
                onPressed: () {
                  provider.completeTrip(trip.id);
                  Navigator.pop(context);
                },
                child: const Text('Complete Trip'),
              ),
            ElevatedButton(
              onPressed: () async {
                if (destinationController.text.isNotEmpty && 
                    budgetController.text.isNotEmpty) {
                  final budget = double.tryParse(budgetController.text) ?? 0;
                  
                  if (trip != null) {
                    await provider.updateTrip(
                      trip.id,
                      destinationController.text,
                      budget,
                      startDate,
                      endDate,
                    );
                  } else {
                    await provider.createTrip(
                      destinationController.text,
                      budget,
                      startDate,
                      endDate,
                    );
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: Text(trip != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, TravelProvider provider) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    TravelExpenseCategory selectedCategory = TravelExpenseCategory.food;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TravelExpenseCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TravelExpenseCategory.values.map((category) {
                    final categoryInfo = _getCategoryInfo(category);
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(categoryInfo['icon'], size: 20),
                          const SizedBox(width: 8),
                          Text(categoryInfo['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (category) {
                    if (category != null) {
                      setState(() => selectedCategory = category);
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Text('Date: ${_formatDate(selectedDate)}'),
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
                if (descriptionController.text.isNotEmpty && 
                    amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  
                  await provider.addExpense(
                    descriptionController.text,
                    amount,
                    selectedCategory,
                    selectedDate,
                  );
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, TravelExpense expense) {
    final categoryInfo = _getCategoryInfo(expense.category);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryInfo['icon'], color: categoryInfo['color']),
                const SizedBox(width: 8),
                Text(
                  categoryInfo['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(expense.date)}'),
            if (expense.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${expense.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement edit functionality
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showTripDetails(BuildContext context, Trip trip, List<TravelExpense> expenses) {
    final totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trip.destination),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duration: ${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}'),
              const SizedBox(height: 8),
              Text('Budget: \$${trip.budget.toStringAsFixed(2)}'),
              Text('Spent: \$${totalSpent.toStringAsFixed(2)}'),
              Text(
                'Remaining: \$${(trip.budget - totalSpent).toStringAsFixed(2)}',
                style: TextStyle(
                  color: totalSpent > trip.budget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Expenses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...expenses.map((expense) {
                final categoryInfo = _getCategoryInfo(expense.category);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(categoryInfo['icon'], size: 16),
                  title: Text(expense.description),
                  trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTripReport(BuildContext context, TravelProvider provider) {
    if (provider.currentTrip == null) return;
    
    final categorySpending = provider.getCategorySpending();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spent: \$${provider.totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Spending by Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...categorySpending.entries.map((entry) {
                final categoryInfo = _getCategoryInfo(entry.key);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(categoryInfo['icon'], size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(categoryInfo['name'])),
                      Text('\$${entry.value.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(TravelExpenseCategory category) {
    switch (category) {
      case TravelExpenseCategory.accommodation:
        return {'name': 'Accommodation', 'icon': Icons.hotel, 'color': Colors.purple};
      case TravelExpenseCategory.food:
        return {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.orange};
      case TravelExpenseCategory.transportation:
        return {'name': 'Transportation', 'icon': Icons.directions_car, 'color': Colors.blue};
      case TravelExpenseCategory.activities:
        return {'name': 'Activities', 'icon': Icons.local_activity, 'color': Colors.green};
      case TravelExpenseCategory.shopping:
        return {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink};
      case TravelExpenseCategory.other:
        return {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}