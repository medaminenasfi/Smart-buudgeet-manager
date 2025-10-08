import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/savings_models.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadSavingsData();
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
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'Savings Goals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.savings, color: Colors.white),
              text: 'Active Goals',
            ),
            Tab(
              icon: Icon(Icons.check_circle, color: Colors.white),
              text: 'Completed',
            ),
            Tab(
              icon: Icon(Icons.analytics, color: Colors.white),
              text: 'Overview',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading savings data...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveGoalsTab(context, provider),
              _buildCompletedGoalsTab(context, provider),
              _buildOverviewTab(context, provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGoalDialog(context),
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveGoalsTab(BuildContext context, SavingsProvider provider) {
    final activeGoals = provider.activeGoalsWithProgress;

    if (activeGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first savings goal to start building your future!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goalWithProgress = activeGoals[index];
        return _buildGoalCard(context, provider, goalWithProgress);
      },
    );
  }

  Widget _buildCompletedGoalsTab(BuildContext context, SavingsProvider provider) {
    final completedGoals = provider.completedGoals.map((goal) => provider.getGoalWithProgress(goal.id)).toList();

    if (completedGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Completed Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete some goals to see your achievements here!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedGoals.length,
      itemBuilder: (context, index) {
        final goalWithProgress = completedGoals[index];
        return _buildCompletedGoalCard(context, goalWithProgress);
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, SavingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewStats(context, provider),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(context, provider),
          const SizedBox(height: 24),
          _buildRecentActivity(context, provider),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsProvider provider, SavingsGoalWithProgress goalWithProgress) {
    final goal = goalWithProgress.goal;
    final categoryInfo = _getCategoryInfo(goal.category);
    final priorityInfo = _getPriorityInfo(goal.priority);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showGoalDetails(context, provider, goalWithProgress),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (categoryInfo['color'] as Color).withOpacity(0.2),
                    child: Icon(
                      categoryInfo['icon'],
                      color: categoryInfo['color'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (priorityInfo['color'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                priorityInfo['name'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: priorityInfo['color'],
                                ),
                              ),
                            ),
                            if (goal.isOverdue) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'OVERDUE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${goalWithProgress.currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${goalWithProgress.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: goalWithProgress.progressPercentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goalWithProgress.progressPercentage >= 100 
                        ? Colors.green 
                        : goal.isOverdue 
                          ? Colors.orange 
                          : Colors.blue,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining: \$${goalWithProgress.remainingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        goal.daysUntilTarget > 0 
                          ? '${goal.daysUntilTarget} days left'
                          : 'Target date passed',
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isOverdue ? Colors.red : Colors.grey,
                          fontWeight: goal.isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddSavingsDialog(context, provider, goal.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Savings'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade600,
                        side: BorderSide(color: Colors.green.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (goalWithProgress.progressPercentage >= 100)
                    ElevatedButton.icon(
                      onPressed: () => _completeGoal(context, provider, goal.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedGoalCard(BuildContext context, SavingsGoalWithProgress goalWithProgress) {
    final goal = goalWithProgress.goal;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: const Icon(Icons.check, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed on ${_formatDate(goal.targetDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${goalWithProgress.currentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Achieved! 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: \$${goal.targetAmount.toStringAsFixed(0)} • Saved: \$${goalWithProgress.currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(BuildContext context, SavingsProvider provider) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Goals',
                    provider.activeGoals.length.toString(),
                    Icons.savings,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    provider.completedGoals.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Target',
                    '\$${provider.totalTargetAmount.toStringAsFixed(0)}',
                    Icons.track_changes,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Saved',
                    '\$${provider.totalSavedAmount.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, SavingsProvider provider) {
    final categorySavings = provider.getCategorySavings();
    final categoriesWithSavings = categorySavings.entries.where((entry) => entry.value > 0).toList();

    if (categoriesWithSavings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Savings by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoriesWithSavings.map((entry) {
              final categoryInfo = _getCategoryInfo(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(categoryInfo['icon'], color: categoryInfo['color'], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoryInfo['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, SavingsProvider provider) {
    final recentRecords = provider.records.take(5).toList();

    if (recentRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((record) {
              final goal = provider.goals.firstWhere((g) => g.id == record.goalId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green.withOpacity(0.2),
                      child: const Icon(Icons.add, color: Colors.green, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatDate(record.date),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+\$${record.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    SavingsGoalCategory selectedCategory = SavingsGoalCategory.other;
    SavingsGoalPriority selectedPriority = SavingsGoalPriority.medium;
    DateTime targetDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
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
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SavingsGoalCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: SavingsGoalCategory.values.map((category) {
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
                DropdownButtonFormField<SavingsGoalPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: SavingsGoalPriority.values.map((priority) {
                    final priorityInfo = _getPriorityInfo(priority);
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: priorityInfo['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priorityInfo['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (priority) {
                    if (priority != null) {
                      setState(() => selectedPriority = priority);
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => targetDate = date);
                    }
                  },
                  child: Text('Target Date: ${_formatDate(targetDate)}'),
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
                if (nameController.text.isNotEmpty && 
                    amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  
                  await context.read<SavingsProvider>().createGoal(
                    nameController.text,
                    descriptionController.text,
                    amount,
                    targetDate,
                    selectedCategory,
                    selectedPriority,
                  );
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context, SavingsProvider provider, String goalId) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Savings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  
                  await provider.addSavingsRecord(
                    goalId,
                    amount,
                    descriptionController.text,
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

  void _showGoalDetails(BuildContext context, SavingsProvider provider, SavingsGoalWithProgress goalWithProgress) {
    final goal = goalWithProgress.goal;
    final records = goalWithProgress.records;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goal.description.isNotEmpty) ...[
                Text(goal.description),
                const SizedBox(height: 16),
              ],
              Text('Target: \$${goal.targetAmount.toStringAsFixed(2)}'),
              Text('Current: \$${goalWithProgress.currentAmount.toStringAsFixed(2)}'),
              Text('Progress: ${goalWithProgress.progressPercentage.toStringAsFixed(1)}%'),
              Text('Target Date: ${_formatDate(goal.targetDate)}'),
              const SizedBox(height: 16),
              const Text(
                'Recent Savings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...records.take(5).map((record) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('\$${record.amount.toStringAsFixed(2)}'),
                subtitle: Text(_formatDate(record.date)),
                trailing: record.description.isNotEmpty ? Text(record.description) : null,
              )),
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

  void _completeGoal(BuildContext context, SavingsProvider provider, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Goal'),
        content: const Text('Are you sure you want to mark this goal as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.completeGoal(goalId);
              Navigator.pop(context);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(SavingsGoalCategory category) {
    switch (category) {
      case SavingsGoalCategory.emergency:
        return {'name': 'Emergency Fund', 'icon': Icons.health_and_safety, 'color': Colors.red};
      case SavingsGoalCategory.vacation:
        return {'name': 'Vacation', 'icon': Icons.flight_takeoff, 'color': Colors.blue};
      case SavingsGoalCategory.house:
        return {'name': 'House', 'icon': Icons.home, 'color': Colors.brown};
      case SavingsGoalCategory.car:
        return {'name': 'Car', 'icon': Icons.directions_car, 'color': Colors.indigo};
      case SavingsGoalCategory.education:
        return {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple};
      case SavingsGoalCategory.retirement:
        return {'name': 'Retirement', 'icon': Icons.elderly, 'color': Colors.teal};
      case SavingsGoalCategory.investment:
        return {'name': 'Investment', 'icon': Icons.trending_up, 'color': Colors.green};
      case SavingsGoalCategory.gadgets:
        return {'name': 'Gadgets', 'icon': Icons.devices, 'color': Colors.orange};
      case SavingsGoalCategory.other:
        return {'name': 'Other', 'icon': Icons.savings, 'color': Colors.grey};
    }
  }

  Map<String, dynamic> _getPriorityInfo(SavingsGoalPriority priority) {
    switch (priority) {
      case SavingsGoalPriority.low:
        return {'name': 'Low', 'color': Colors.grey};
      case SavingsGoalPriority.medium:
        return {'name': 'Medium', 'color': Colors.orange};
      case SavingsGoalPriority.high:
        return {'name': 'High', 'color': Colors.red};
      case SavingsGoalPriority.urgent:
        return {'name': 'Urgent', 'color': Colors.deepOrange};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}