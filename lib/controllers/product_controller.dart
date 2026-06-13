import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart'; // تأكد من صحة مسار ملف السيرفس لديك

class ProductController extends ChangeNotifier {
  // استدعاء نسخة من السيرفس للاعتماد عليها
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // 1. جلب المنتجات عبر السيرفس
  Future<void> loadProducts() async {
    _isLoading = true;
    // لا نضع notifyListeners هنا مباشرة لتفادي مشاكل البناء أثناء initState لشاشة العرض

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // تحديث فوري للواجهة
    }
  }

  // 2. إضافة منتج وتحديث القائمة محلياً فوراً
  Future<void> addProduct(Product product) async {
    try {
      // إرسال المنتج للسيرفر وانتظار النتيجة (التي تحتوي الـ ID المنشأ من قاعدة البيانات)
      final Product savedProduct = await _productService.addProduct(product);

      // تحديث الحالة المحلية للتطبيق بدون إعادة جلب كل المنتجات من السيرفر
      _products.add(savedProduct);
      notifyListeners();
    } catch (e) {
      print("Error adding product: $e");
      rethrow; // نمرر الخطأ لتلتقطه شاشة AddProductScreen وتعرض الـ SnackBar الأحمر
    }
  }

  // 3. تعديل منتج
  Future<void> updateProduct(int id, Product product) async {
    try {
      final Product updatedProduct =
          await _productService.updateProduct(id, product);
      int index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating product: $e");
      rethrow;
    }
  }

  // 4. حذف منتج بالتزامن مع الباكيند
  Future<void> deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting product: $e");
      rethrow;
    }
  }
}
