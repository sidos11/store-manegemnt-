import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale.dart';

class SaleService {
  final String baseUrl = 'http://localhost:8080/api/sales';

  // GET toutes les ventes
  Future<List<Sale>> getSales() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement ventes');
    }
  }

  // POST ajouter une vente
  Future<Sale> addSale(Sale sale) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sale.toJson()),
    );
    if (response.statusCode == 201) {
      return Sale.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ajout vente');
    }
  }

  // GET ventes par date
  Future<List<Sale>> getSalesByDate(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/date/$date'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement ventes par date');
    }
  }
}