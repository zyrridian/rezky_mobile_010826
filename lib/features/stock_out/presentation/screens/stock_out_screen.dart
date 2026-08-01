import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_out_controller.dart';
import 'package:intl/intl.dart';

class StockOutScreen extends ConsumerStatefulWidget {
  const StockOutScreen({super.key});

  @override
  ConsumerState<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends ConsumerState<StockOutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(stockOutControllerProvider.notifier).fetchStockOuts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockOutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Keluar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final path = await ref.read(stockOutControllerProvider.notifier).exportCsv();
              if (!mounted) return;
              if (path == 'WEB_DOWNLOADED') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mendownload CSV.')));
              } else if (path != null && path != 'WEB_NOT_SUPPORTED') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil diekspor ke: $path')));
              }
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_stock_out',
        onPressed: () => Navigator.pushNamed(context, '/add_stock_out'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(StockOutState state) {
    if (state is StockOutLoading || state is StockOutInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is StockOutError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is StockOutLoaded) {
      if (state.data.isEmpty) {
        return const Center(child: Text('Belum ada transaksi barang keluar.'));
      }
      return ListView.builder(
        itemCount: state.data.length,
        itemBuilder: (context, index) {
          final item = state.data[index];
          return ListTile(
            title: Text('${item.itemName} (-${item.quantity})'),
            subtitle: Text('Tanggal: ${DateFormat('yyyy-MM-dd HH:mm').format(item.date)}'),
            trailing: Text(item.destination ?? '-'),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
