import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../controllers/sale_controller.dart';
import '../models/sale.dart';
import 'package:store_management/l10n/app_localizations.dart';

class SalesScreenModern extends StatefulWidget {
  const SalesScreenModern({super.key});

  @override
  State<SalesScreenModern> createState() => _SalesScreenModernState();
}

class _SalesScreenModernState extends State<SalesScreenModern> {
  int? _selectedProductId;
  String? _selectedProductName;
  double? _selectedProductPrice;
  final _quantityController = TextEditingController();
  bool _isSubmitting = false; // لمنع المستخدم من الضغط المزدوج أثناء الإرسال

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductController>().loadProducts());
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFba1a1a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF006c4f),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedProductId == null) {
      _showErrorSnackBar(l10n.selectProduct);
      return;
    }

    if (_quantityController.text.isEmpty) {
      _showErrorSnackBar('${l10n.quantity} ${l10n.fillAllFields}');
      return;
    }

    int? quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showErrorSnackBar('Please enter a valid quantity');
      return;
    }

    final productController = context.read<ProductController>();
    final products = productController.products;
    final hasProduct = products.any((p) => p.id == _selectedProductId);

    if (!hasProduct) {
      _showErrorSnackBar('Product not found');
      return;
    }

    final product = products.firstWhere((p) => p.id == _selectedProductId);

    if (product.quantity < quantity) {
      _showErrorSnackBar('Not enough stock. Available: ${product.quantity}');
      return;
    }

    final totalPrice = (_selectedProductPrice ?? 0) * quantity;
    final now = DateTime.now().toIso8601String();

    final sale = Sale(
      productId: _selectedProductId!,
      productName: _selectedProductName!,
      quantity: quantity,
      totalPrice: totalPrice,
      date: now,
    );

    setState(() => _isSubmitting = true);

    try {
      // 1. إرسال عملية البيع للسيرفر عبر الكنترولر المحمي بالتوكن
      await context.read<SaleController>().addSale(sale);

      // 2. تحديث المنتجات من السيرفر مباشرة لضمان المزامنة المطلقة للمخزن دون تعديل يدوي
      await productController.loadProducts();

      _showSuccessSnackBar(l10n.saleRecorded);

      setState(() {
        _selectedProductId = null;
        _selectedProductName = null;
        _selectedProductPrice = null;
        _quantityController.clear();
      });
    } catch (e) {
      _showErrorSnackBar(
          'Error recording sale on server. Please check connection or JWT.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final l10n = AppLocalizations.of(context)!;

    final bool productExists = products.any((p) => p.id == _selectedProductId);
    final int? safeSelectedId = productExists ? _selectedProductId : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4361ee), Color(0xFF605bea)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newSale,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        l10n.recordSale,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.point_of_sale,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.selectProduct,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFe1e3e4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<int>(
                  value: safeSelectedId,
                  hint: Text(
                    l10n.selectProduct,
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: products.map((p) {
                    return DropdownMenuItem<int>(
                      value: p.id,
                      child: Text(
                        '${p.name} — ${p.price.toStringAsFixed(0)} MRU (${p.quantity} p.)',
                      ),
                    );
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            final product =
                                products.firstWhere((p) => p.id == value);
                            setState(() {
                              _selectedProductId = value;
                              _selectedProductName = product.name;
                              _selectedProductPrice = product.price;
                            });
                          }
                        },
                  isExpanded: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFe1e3e4)),
              ),
              child: TextField(
                controller: _quantityController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.quantitySold,
                  prefixIcon: const Icon(
                    Icons.numbers,
                    color: Color(0xFF4361ee),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            if (safeSelectedId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Stock available: ${products.firstWhere((p) => p.id == safeSelectedId).quantity} units',
                  style: const TextStyle(
                    color: Color(0xFF4361ee),
                    fontSize: 12,
                  ),
                ),
              ),
            if (_selectedProductPrice != null &&
                _quantityController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((_selectedProductPrice ?? 0) * (int.tryParse(_quantityController.text) ?? 0)).toStringAsFixed(0)} MRU',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361ee),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l10n.add,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
