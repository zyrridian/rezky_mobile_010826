import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/login_controller.dart';
import '../../../auth/presentation/providers/login_state.dart';
import '../../../items/presentation/providers/item_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemControllerProvider.notifier).fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(loginControllerProvider);
    final itemState = ref.watch(itemControllerProvider);
    
    String role = 'operator';
    String email = '';
    
    if (authState is AuthSuccess) {
      role = authState.user.role;
      email = authState.user.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gudang Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Usually we'd call logout on the controller, but for now just pop to login
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, $email', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Text('Role: ${role.toUpperCase()}', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            if (role == 'admin') ...[
              _buildMenuButton(context, 'Master Barang', Icons.inventory, '/items'),
              const SizedBox(height: 16),
            ],
            _buildMenuButton(context, 'Transaksi Barang Masuk', Icons.arrow_downward, '/stock_in'),
            const SizedBox(height: 16),
            _buildMenuButton(context, 'Transaksi Barang Keluar', Icons.arrow_upward, '/stock_out'),
            const SizedBox(height: 32),
            if (itemState is ItemLoaded) ...[
              const Text('Low Stock Alerts ( < 10 )', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              ...itemState.items.where((item) => item.currentStock < 10).map((item) {
                return Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(item.name),
                    trailing: Text('Stok: ${item.currentStock}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, String route) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}
