import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/items/presentation/screens/items_screen.dart';
import 'features/items/presentation/screens/add_item_screen.dart';
import 'features/stock_in/presentation/screens/stock_in_screen.dart';
import 'features/stock_in/presentation/screens/add_stock_in_screen.dart';
import 'features/stock_out/presentation/screens/stock_out_screen.dart';
import 'features/stock_out/presentation/screens/add_stock_out_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/items': (context) => const ItemsScreen(),
        '/add_item': (context) => const AddItemScreen(),
        '/stock_in': (context) => const StockInScreen(),
        '/add_stock_in': (context) => const AddStockInScreen(),
        '/stock_out': (context) => const StockOutScreen(),
        '/add_stock_out': (context) => const AddStockOutScreen(),
      },
    );
  }
}
