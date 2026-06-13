import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale.dart';

class SaleService {
  final String baseUrl = 'http://localhost:8080/api/sales';

  // 🌟 ضع توكن الـ JWT الخاص بك هنا لتخطي حماية السيرفر (خطأ 403)
  final String jwtToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyNDAzN0BzdXBudW0ubXIiLCJpYXQiOjE3ODEzMTYzMDAsImV4cCI6MTc4MTQwMjcwMH0.ZZxKTqcHWNc9kEbLqvCB2_UNuWJgzR6qF7kbVcxhKjk";

  // دالة موحدة لإنشاء الـ Headers مضافاً إليها توكن الحماية
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }

  // GET: جلب جميع المبيعات
  Future<List<Sale>> getSales() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _getHeaders());
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      print(
          "🚨 SaleService GET Error: ${response.statusCode} | ${response.body}");
      throw Exception('Erreur chargement ventes');
    }
  }

  // POST: إضافة عملية بيع جديدة
  Future<Sale> addSale(Sale sale) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
      body: jsonEncode(sale.toJson()),
    );
    // السيرفر قد يعيد 201 أو 200 عند نجاح الحفظ
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Sale.fromJson(jsonDecode(response.body));
    } else {
      print(
          "🚨 SaleService POST Error: ${response.statusCode} | ${response.body}");
      throw Exception('Erreur ajout vente: ${response.statusCode}');
    }
  }

  // GET: جلب المبيعات حسب التاريخ
  Future<List<Sale>> getSalesByDate(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/date/$date'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      print("🚨 SaleService GET by Date Error: ${response.statusCode}");
      throw Exception('Erreur chargement ventes par date');
    }
  }
}
