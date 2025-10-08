import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../providers/travel_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load data after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final monthlyProvider = Provider.of<MonthlyBudgetProvider>(context, listen: false);
      final specialProvider = Provider.of<SpecialPurchaseProvider>(context, listen: false);
      final travelProvider = Provider.of<TravelProvider>(context, listen: false);
      final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);

      await Future.wait([
        monthlyProvider.loadMonthlyData(_currentDate.month, _currentDate.year),
        specialProvider.loadSpecialPurchaseData(_currentDate.month, _currentDate.year),
        travelProvider.loadTravelData(),
        savingsProvider.loadSavingsData(),
      ]);
    } catch (e) {
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
      appBar: const CustomAppBar(
        title: AppConstants.appName,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildBudgetOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(_currentDate);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Your Budget',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Track your expenses, manage your goals, and take control of your finances.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildMonthlyBudgetCard(),
        const SizedBox(height: 16),
        _buildSpecialPurchasesCard(),
        const SizedBox(height: 16),
        _buildTravelBudgetCard(),
        const SizedBox(height: 16),
        _buildSavingsCard(),
      ],
    );
  }

  Widget _buildMonthlyBudgetCard() {
    return Consumer<MonthlyBudgetProvider>(
      builder: (context, provider, child) {
        final budget = provider.currentBudget?.amount ?? 0.0;
        final spent = provider.totalSpent;
        final remaining = provider.remainingBudget;
        final percentage = provider.budgetPercentageUsed;

        return BudgetCard(
          title: 'Monthly Expenses',
          totalBudget: budget.toStringAsFixed(2),
          spent: spent.toStringAsFixed(2),
          remaining: remaining.toStringAsFixed(2),
          percentage: percentage,
          color: AppConstants.monthlyColor,
          icon: Icons.calendar_month,
          onTap: () {
            Navigator.pushNamed(context, '/monthly-expenses');
          },
        );
      },
    );
  }

  Widget _buildSpecialPurchasesCard() {
    return Consumer<SpecialPurchaseProvider>(
      builder: (context, provider, child) {
        final budget = provider.currentBudget?.amount ?? 0.0;
        final spent = provider.totalSpent;
        final remaining = provider.remainingBudget;
        final percentage = provider.budgetPercentageUsed;

        return BudgetCard(
          title: 'Special Purchases',
          totalBudget: budget.toStringAsFixed(2),
          spent: spent.toStringAsFixed(2),
          remaining: remaining.toStringAsFixed(2),
          percentage: percentage,
          color: AppConstants.specialColor,
          icon: Icons.shopping_bag,
          onTap: () {
            Navigator.pushNamed(context, '/special-purchases');
          },
        );
      },
    );
  }

  Widget _buildTravelBudgetCard() {
    return Consumer<TravelProvider>(
      builder: (context, provider, child) {
        // For travel, we'll show the current trip budget
        final budget = provider.currentTrip?.budget ?? 0.0;
        final spent = provider.totalSpent;
        final remaining = budget - spent;
        final percentage = budget > 0 ? (spent / budget * 100).clamp(0.0, 100.0) : 0.0;

        return BudgetCard(
          title: 'Travel Budget',
          totalBudget: budget.toStringAsFixed(2),
          spent: spent.toStringAsFixed(2),
          remaining: remaining.toStringAsFixed(2),
          percentage: percentage,
          color: AppConstants.travelColor,
          icon: Icons.flight,
          onTap: () {
            Navigator.pushNamed(context, '/travel');
          },
        );
      },
    );
  }

  Widget _buildSavingsCard() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        // For savings, we'll show aggregate data
        final totalTarget = provider.totalTargetAmount;
        final totalSaved = provider.totalSavedAmount;
        final remaining = totalTarget - totalSaved;
        final percentage = totalTarget > 0 ? (totalSaved / totalTarget * 100).clamp(0.0, 100.0) : 0.0;

        return BudgetCard(
          title: 'Savings Goals',
          totalBudget: totalTarget.toStringAsFixed(2),
          spent: totalSaved.toStringAsFixed(2),
          remaining: remaining.toStringAsFixed(2),
          percentage: percentage,
          color: AppConstants.savingsColor,
          icon: Icons.savings,
          onTap: () {
            Navigator.pushNamed(context, '/savings');
          },
        );
      },
    );
  }
}