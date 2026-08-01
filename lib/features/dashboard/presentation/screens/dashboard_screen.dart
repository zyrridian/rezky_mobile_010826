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
    String email = 'user';
    
    if (authState is AuthSuccess) {
      role = authState.user.role;
      email = authState.user.email;
    }

    int totalItems = 0;
    int totalCategories = 0;
    int lowStockCount = 0;
    int totalStock = 0;

    if (itemState is ItemLoaded) {
      totalItems = itemState.items.length;
      totalCategories = itemState.items.map((e) => e.category).toSet().length;
      lowStockCount = itemState.items.where((e) => e.currentStock < 10).length;
      totalStock = itemState.items.fold(0, (sum, item) => sum + item.currentStock);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dashboard_rounded, color: Color(0xFFFFB300), size: 32),
                      SizedBox(width: 8),
                      Text('WAREMANAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(role.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Main Red Card (Alerts)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4B4B), Color(0xFFFF2156)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.show_chart, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text('$lowStockCount', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const Text('Low Stock Alerts (< 10)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Total\nSKU', '$totalItems', const Color(0xFF2E6FF2))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total\nKategori', '$totalCategories', const Color(0xFF7A00E6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Total\nStok', '$totalStock', const Color(0xFF5100D5))),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Low Stock List
              if (itemState is ItemLoaded && lowStockCount > 0) ...[
                const Text('Need Attention', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...itemState.items.where((item) => item.currentStock < 10).take(5).map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('SKU: ${item.sku}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                        Text('${item.currentStock}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.red)),
                      ],
                    ),
                  );
                }),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 24),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
        ],
      ),
    );
  }
}
