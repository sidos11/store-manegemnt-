import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://localhost:8080/api/products';

  // 🌟 التوكن الذي منحه لك السيرفر عند تسجيل الدخول
  final String jwtToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyNDAzN0BzdXBudW0ubXIiLCJpYXQiOjE3ODEzMTYzMDAsImV4cCI6MTc4MTQwMjcwMH0.ZZxKTqcHWNc9kEbLqvCB2_UNuWJgzR6qF7kbVcxhKjk";

  // دالة موحدة لإنشاء الـ Headers مضافاً إليها توكن الحماية لمنع خطأ 403
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $jwtToken', // تمرير التوكن للسيرفر
    };
  }

  // GET: جلب جميع المنتجات
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _getHeaders());
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      print("🚨 Error GET: ${response.statusCode} | Body: ${response.body}");
      throw Exception('Erreur chargement produits: ${response.statusCode}');
    }
  }

  // POST: إضافة منتج جديد
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      print("🚨 Error POST: ${response.statusCode} | Body: ${response.body}");
      throw Exception('Erreur ajout produit: ${response.statusCode}');
    }
  }

  // PUT: تعديل منتج (الدالة التي كانت مفقودة وتسببت في الخطأ)
  Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      print("🚨 Error PUT: ${response.statusCode} | Body: ${response.body}");
      throw Exception('Erreur modification produit: ${response.statusCode}');
    }
  }

  // DELETE: حذف منتج (الدالة التي كانت مفقودة وتسببت في الخطأ)
  Future<void> deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      print("🚨 Error DELETE: ${response.statusCode} | Body: ${response.body}");
      throw Exception('Erreur suppression produit: ${response.statusCode}');
    }
  }
}
