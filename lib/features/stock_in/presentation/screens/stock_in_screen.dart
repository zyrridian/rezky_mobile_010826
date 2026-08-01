import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_in_controller.dart';
import 'package:intl/intl.dart';

class StockInScreen extends ConsumerStatefulWidget {
  const StockInScreen({super.key});

  @override
  ConsumerState<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends ConsumerState<StockInScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(stockInControllerProvider.notifier).fetchStockIns());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockInControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Barang Masuk')),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_stock_in'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(StockInState state) {
    if (state is StockInLoading || state is StockInInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is StockInError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is StockInLoaded) {
      if (state.data.isEmpty) {
        return const Center(child: Text('Belum ada transaksi barang masuk.'));
      }
      return ListView.builder(
        itemCount: state.data.length,
        itemBuilder: (context, index) {
          final item = state.data[index];
          return ListTile(
            title: Text('${item.itemName} (+${item.quantity})'),
            subtitle: Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm').format(item.date)}'),
            trailing: Text(item.remarks ?? '-'),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
