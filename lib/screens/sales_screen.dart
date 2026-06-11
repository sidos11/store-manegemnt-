import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../controllers/sale_controller.dart';
import '../models/sale.dart';
import 'package:store_management/l10n/app_localizations.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  int? _selectedProductId;
  String? _selectedProductName;
  double? _selectedProductPrice;
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductController>().loadProducts());
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedProductId == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillAllFields),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final totalPrice = (_selectedProductPrice ?? 0) * quantity;
    final now = DateTime.now().toIso8601String();

    final sale = Sale(
      productId: _selectedProductId!,
      productName: _selectedProductName!,
      quantity: quantity,
      totalPrice: totalPrice,
      date: now,
    );

    await context.read<SaleController>().addSale(sale);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.saleRecorded),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    setState(() {
      _selectedProductId = null;
      _selectedProductName = null;
      _selectedProductPrice = null;
      _quantityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998E).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.newSale,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      const Text('Enregistrer',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.point_of_sale,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('Sélection',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 16),

            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<int>(
                  value: _selectedProductId,
                  hint: Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text(l10n.selectProduct,
                          style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: products.map((p) {
                    return DropdownMenuItem<int>(
                      value: p.id,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF11998E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag,
                                color: Color(0xFF11998E), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text('${p.name} — ${p.price} MRU',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final product = products.firstWhere((p) => p.id == value);
                    setState(() {
                      _selectedProductId = value;
                      _selectedProductName = product.name;
                      _selectedProductPrice = product.price;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.quantitySold,
                  prefixIcon:
                      const Icon(Icons.numbers, color: Color(0xFF11998E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),

            // Prix total preview
            if (_selectedProductPrice != null &&
                _quantityController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${((_selectedProductPrice ?? 0) * (int.tryParse(_quantityController.text) ?? 0)).toStringAsFixed(2)} MRU',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white),
                label: Text(l10n.recordSale,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11998E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
