import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_in_controller.dart';
import '../../../items/presentation/providers/item_controller.dart';

class AddStockInScreen extends ConsumerStatefulWidget {
  const AddStockInScreen({super.key});

  @override
  ConsumerState<AddStockInScreen> createState() => _AddStockInScreenState();
}

class _AddStockInScreenState extends ConsumerState<AddStockInScreen> {
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();
  int? _selectedItemId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemControllerProvider.notifier).fetchItems());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockInState = ref.watch(stockInControllerProvider);
    final itemState = ref.watch(itemControllerProvider);

    ref.listen<StockInState>(stockInControllerProvider, (previous, next) {
      if (next is StockInError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message), backgroundColor: Colors.red));
      } else if (next is StockInLoaded && previous is StockInLoading) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (itemState is ItemLoading) const CircularProgressIndicator()
            else if (itemState is ItemLoaded) 
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pilih Barang', border: OutlineInputBorder()),
                value: _selectedItemId,
                items: itemState.items.map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text('${e.name} (${e.sku})'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedItemId = val),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController, 
              decoration: const InputDecoration(labelText: 'Jumlah', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _remarksController, 
              decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: stockInState is StockInLoading || _selectedItemId == null
                    ? null
                    : () {
                        final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
                        if (qty <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah tidak valid')));
                          return;
                        }
                        ref.read(stockInControllerProvider.notifier).addStockIn(
                          DateTime.now(),
                          _selectedItemId!,
                          qty,
                          _remarksController.text.trim(),
                        );
                      },
                child: stockInState is StockInLoading ? const CircularProgressIndicator() : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
