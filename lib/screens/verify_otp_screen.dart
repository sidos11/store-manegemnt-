import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_management/l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import '../services/auth_service.dart'; // Importation de notre service d'API

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  bool _isLoading = false; // Indicateur pour l'appel de vérification
  bool _isResending = false; // Indicateur pour le renvoi d'OTP

  // Lógica : Rassembler les 4 chiffres et envoyer au Backend
  void _handleVerifyOtp(String email) async {
    // Combine les textes des 4 contrôleurs pour former le code complet (ex: "1234")
    String codeSaisi = _controllers.map((c) => c.text).join().trim();

    if (codeSaisi.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter the complete 4-digit code.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Appel à l'API : /api/v1/auth/verify-otp
    bool isVerified = await AuthService.verifyOtp(email, codeSaisi);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isVerified) {
      // Succès : Passage à la réinitialisation finale en transmettant l'email
      Navigator.pushNamed(
        context,
        '/reset-password',
        arguments: email,
      );
    } else {
      // Échec : Code incorrect ou expiré
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid or expired OTP code. Please try again."),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
    }
  }

  // Lógica : Renvoyer un nouveau code OTP si demandé
  void _handleResendCode(String email) async {
    if (email == 'your account') return;

    setState(() {
      _isResending = true;
    });

    bool otpSent = await AuthService.sendOtp(email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A new code has been sent to your console!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to resend code. Please try again later."),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Récupération sécurisée de l'email passé en argument
    final emailArguments =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'your account';

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
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2346D5).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_outlined,
                              color: Color(0xFF2346D5), size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Verify Email',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191C1D)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a 4-digit code to\n$emailArguments",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF444655),
                              height: 1.4),
                        ),
                        const SizedBox(height: 24),

                        // Ligne des 4 champs OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 56,
                              height: 64,
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                enabled: !_isLoading,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFC4C5D7)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF2346D5), width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                  if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  // Soumission automatique si le dernier chiffre est rempli
                                  if (value.length == 1 && index == 3) {
                                    _handleVerifyOtp(emailArguments);
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Bouton principal dynamique
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
                                : () => _handleVerifyOtp(emailArguments),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Verify & Continue',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section Renvoi du code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Didn't receive the code? ",
                                style: TextStyle(
                                    color: Color(0xFF444655), fontSize: 13)),
                            _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Color(0xFF2346D5),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () =>
                                        _handleResendCode(emailArguments),
                                    child: const Text(
                                      'Resend Code',
                                      style: TextStyle(
                                          color: Color(0xFF2346D5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                          ],
                        )
                      ],
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
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
