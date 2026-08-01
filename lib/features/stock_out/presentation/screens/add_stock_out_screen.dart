import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_out_controller.dart';
import '../../../items/presentation/providers/item_controller.dart';
import '../../../items/domain/entities/item_entity.dart';

class AddStockOutScreen extends ConsumerStatefulWidget {
  const AddStockOutScreen({super.key});

  @override
  ConsumerState<AddStockOutScreen> createState() => _AddStockOutScreenState();
}

class _AddStockOutScreenState extends ConsumerState<AddStockOutScreen> {
  final _quantityController = TextEditingController();
  final _destinationController = TextEditingController();
  ItemEntity? _selectedItem;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemControllerProvider.notifier).fetchItems());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockOutState = ref.watch(stockOutControllerProvider);
    final itemState = ref.watch(itemControllerProvider);

    ref.listen<StockOutState>(stockOutControllerProvider, (previous, next) {
      if (next is StockOutError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message), backgroundColor: Colors.red));
      } else if (next is StockOutLoaded && previous is StockOutLoading) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Keluar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (itemState is ItemLoading) const CircularProgressIndicator()
            else if (itemState is ItemLoaded) 
              DropdownButtonFormField<ItemEntity>(
                decoration: const InputDecoration(labelText: 'Pilih Barang', border: OutlineInputBorder()),
                value: _selectedItem,
                items: itemState.items.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text('${e.name} (${e.sku}) - Stok: ${e.currentStock}'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedItem = val),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController, 
              decoration: const InputDecoration(labelText: 'Jumlah', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController, 
              decoration: const InputDecoration(labelText: 'Tujuan', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: stockOutState is StockOutLoading || _selectedItem == null
                    ? null
                    : () {
                        final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
                        if (qty <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah tidak valid')));
                          return;
                        }
                        if (qty > _selectedItem!.currentStock) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok tidak mencukupi!')));
                          return;
                        }

                        ref.read(stockOutControllerProvider.notifier).addStockOut(
                          DateTime.now(),
                          _selectedItem!.id,
                          qty,
                          _destinationController.text.trim(),
                        );
                      },
                child: stockOutState is StockOutLoading ? const CircularProgressIndicator() : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
