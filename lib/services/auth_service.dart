import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // عنوان السيرفر المحلي الأكثر استقراراً على Linux
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1/auth';

  // 1. التسجيل الجديد (Register)
  static Future<bool> register(
      String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('================ BACKEND REGISTER SUCCESS ================');
        print('User registered successfully!');
        return true;
      } else {
        print(
            'Échec de l\'inscription : ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion HTTP lors du Register : $e');
      return false;
    }
  }

  // 2. تسجيل الدخول وحفظ التوكن (Login)
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        String token = responseData['token'];
        String name = responseData['name'] ?? '';

        // 🌟 خطوة جوهرية: حفظ التوكن في ذاكرة الجهاز لكي يعمل الـ Logout لاحقاً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        print('================ BACKEND CONNEXION SUCCESS ================');
        print('Bienvenue $name !');
        print('Votre Token JWT : $token');
        print('===========================================================');

        return true;
      } else {
        print(
            'Échec de la connexion : ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur de connexion HTTP avec le backend : $e');
      return false;
    }
  }

  // 3. طلب الـ OTP (Mot de passe oublié)
  static Future<bool> sendOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur sendOtp : $e');
      return false;
    }
  }

  // 4. التحقق من رمز الـ OTP
  static Future<bool> verifyOtp(String email, String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur verifyOtp : $e');
      return false;
    }
  }

  // 5. تعيين كلمة المرور الجديدة
  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur resetPassword : $e');
      return false;
    }
  }

  // 6. تسجيل الخروج وتطهير الجلسة (Logout)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      // إعلام السيرفر بتسجيل الخروج لتعطيل التوكن في السيرفر
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));
      }

      // تدمير التوكن المخزن محلياً تماماً
      await prefs.remove('jwt_token');
      print('================ SESSION CLEARED SUCCESSFULLY ================');
      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      // حماية احتياطية: إذا فشلت شبكة الاتصال، نمسح التوكن محلياً على كل حال لضمان خروج المستخدم
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      return true;
    }
  }
}
