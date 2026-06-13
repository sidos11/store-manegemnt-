import 'package:flutter/material.dart';
import 'package:store_management/l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import '../services/auth_service.dart'; // Importation indispensable pour l'API

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading =
      false; // Permet de bloquer le bouton et afficher un spinner pendant l'appel

  // Méthode de communication asynchrone avec Spring Boot
  void _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();

      // Appel à l'API : /api/v1/auth/forgot-password
      bool otpSent = await AuthService.sendOtp(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (otpSent) {
        // Succès : Passage à la vérification OTP avec l'email en argument
        Navigator.pushNamed(
          context,
          '/verify-otp',
          arguments: email,
        );
      } else {
        // Échec : L'email n'existe pas ou le serveur ne répond pas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not found or server error. Please try again."),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bouton retour à la connexion
                          TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text(
                                'Back to login'), // Vous pouvez utiliser l'i18n ici si présent : l10n.backToLogin
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2346D5),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191C1D)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter the email address associated with your account and we'll send you a verification code.",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444655),
                                height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // Label Email traduit dynamiquement s'il existe dans votre l10n
                          const Text(
                            'Email Address',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF191C1D)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            enabled:
                                !_isLoading, // Désactive le champ pendant le chargement
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              prefixIcon: const Icon(Icons.mail_outline,
                                  color: Color(0xFF747686)),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFC4C5D7)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF2346D5), width: 2),
                              ),
                            ),
                            validator: (value) =>
                                value == null || !value.contains('@')
                                    ? 'Please enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 24),

                          // Bouton d'action dynamique
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2346D5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _handleSendOtp,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Send Code',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                        SizedBox(width: 8),
                                        Icon(Icons.send, size: 16),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
