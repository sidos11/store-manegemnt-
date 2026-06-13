import 'package:flutter/material.dart';
import 'package:store_management/l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import '../services/auth_service.dart'; // Importation indispensable pour l'appel API

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSuccess = false; // Permet de basculer sur l'état de succès graphique
  bool _isLoading =
      false; // Bloque les actions pendant la modification sur Spring Boot

  // LOGIQUE DU BACKEND : Soumission du nouveau mot de passe
  void _handleResetPassword(String email) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String newPassword = _passwordController.text.trim();

      // Appel de l'API : /api/v1/auth/reset-password
      bool isResetSuccessful =
          await AuthService.resetPassword(email, newPassword);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (isResetSuccessful) {
        setState(() {
          _isSuccess = true; // Bascule l'écran sur la vue "Succès"
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "An error occurred while resetting your password. Please try again."),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Récupération de l'email passé en argument depuis l'écran précédent (VerifyOtpScreen)
    final String emailArguments =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

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
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 400),
                      crossFadeState: _isSuccess
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,

                      // PREMIÈRE VUE : Formulaire de nouveau mot de passe
                      firstChild: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set New Password',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF191C1D)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Create a strong password that you haven't used before.",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF444655),
                                  height: 1.4),
                            ),
                            const SizedBox(height: 24),

                            // Champ Nouveau Mot de passe
                            const Text('New Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF191C1D))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: _buildInputDecoration(
                                  'Min. 8 characters', Icons.lock_outline),
                              validator: (value) =>
                                  value == null || value.length < 8
                                      ? 'Password must be at least 8 characters'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            // Champ Confirmation
                            const Text('Confirm Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF191C1D))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              enabled: !_isLoading,
                              decoration: _buildInputDecoration(
                                  'Repeat new password', Icons.lock_reset),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Bouton de réinitialisation dynamique
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
                                onPressed: _isLoading
                                    ? null
                                    : () =>
                                        _handleResetPassword(emailArguments),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : const Text('Reset Password',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // DEUXIÈME VUE : Confirmation de mise à jour réussie
                      secondChild: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFF51FAC1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle,
                                color: Color(0xFF00513B), size: 48),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Password Updated!',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191C1D)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your account security has been updated. You can now log in with your new credentials.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444655),
                                height: 1.4),
                          ),
                          const SizedBox(height: 24),
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
                              onPressed: () {
                                // Redirection sécurisée et vidage de la pile vers l'écran de Login
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              },
                              child: const Text('Back to Login',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '© 2026 SMS Store. Managed Security Solutions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0x99444655)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF747686)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC4C5D7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2346D5), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
