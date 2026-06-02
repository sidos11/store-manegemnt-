import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> products = [];
  bool isLoading = false;
  String errorMessage = '';

  // Charger tous les produits
  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      products = await _service.getProducts();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Ajouter un produit
  Future<void> addProduct(Product product) async {
    try {
      await _service.addProduct(product);
      await loadProducts();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Modifier un produit
  Future<void> updateProduct(int id, Product product) async {
    try {
      await _service.updateProduct(id, product);
      await loadProducts();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}