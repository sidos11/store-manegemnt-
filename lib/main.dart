import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:store_management/l10n/app_localizations.dart';

// ✅ Toutes les screens depuis screens/ — cohérent avec profile_screen.dart
import 'package:store_management/screens/login_screen.dart';
import 'package:store_management/screens/register_screen.dart';
import 'package:store_management/screens/profile_screen.dart';
import 'package:store_management/screens/forgot_password_screen.dart';
import 'package:store_management/screens/verify_otp_screen.dart';
import 'package:store_management/screens/reset_password_screen.dart';
import 'package:store_management/screens/product_screen.dart';
import 'package:store_management/screens/add_product_screen.dart';

// ✅ Controllers (Provider)
import 'package:store_management/controllers/product_controller.dart';
import 'package:store_management/controllers/sale_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => SaleController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2346D5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2346D5),
          primary: const Color(0xFF2346D5),
          surface: const Color(0xFFF8F9FA),
          error: const Color(0xFFBA1A1A),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/products': (context) => const ProductScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-otp': (context) => const VerifyOtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
