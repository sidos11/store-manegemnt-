import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';

class SaleController extends ChangeNotifier {
  final SaleService _service = SaleService();

  List<Sale> sales = [];
  bool isLoading = false;
  String errorMessage = '';
  double totalProfit = 0;

  // Charger toutes les ventes
  Future<void> loadSales() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      sales = await _service.getSales();
      calculateProfit();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Ajouter une vente
  Future<void> addSale(Sale sale) async {
    try {
      await _service.addSale(sale);
      await loadSales();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Charger ventes par date
  Future<void> loadSalesByDate(String date) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      sales = await _service.getSalesByDate(date);
      calculateProfit();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Calculer le profit total
  void calculateProfit() {
    totalProfit = sales.fold(0, (sum, sale) => sum + sale.totalPrice);
  }
}