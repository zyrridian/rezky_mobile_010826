import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../../../items/presentation/screens/items_screen.dart';
import '../../../stock_in/presentation/screens/stock_in_screen.dart';
import '../../../stock_out/presentation/screens/stock_out_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ItemsScreen(),
    const StockInScreen(),
    const StockOutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: 'Stok Masuk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_rounded),
            label: 'Stok Keluar',
          ),
        ],
      ),
    );
  }
}
