import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/login_controller.dart';
import '../../../auth/presentation/providers/login_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(loginControllerProvider);
    
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $email', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Text('Role: ${role.toUpperCase()}', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            _buildMenuButton(context, 'Master Barang', Icons.inventory, '/items'),
            const SizedBox(height: 16),
            _buildMenuButton(context, 'Transaksi Barang Masuk', Icons.arrow_downward, '/stock_in'),
            const SizedBox(height: 16),
            _buildMenuButton(context, 'Transaksi Barang Keluar', Icons.arrow_upward, '/stock_out'),
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
