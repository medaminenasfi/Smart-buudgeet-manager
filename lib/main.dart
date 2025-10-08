import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'screens/monthly_expenses_screen.dart';
import 'screens/special_purchases_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const SmartBudgetManagerApp());
}

class SmartBudgetManagerApp extends StatelessWidget {
  const SmartBudgetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MonthlyBudgetProvider()),
        ChangeNotifierProvider(create: (_) => SpecialPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => TravelBudgetProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/monthly-expenses': (context) => const MonthlyExpensesScreen(),
          '/special-purchases': (context) => const SpecialPurchasesScreen(),
          // We'll add more routes as we create the other screens
        },
      ),
    );
  }
}
