import 'package:flutter/material.dart';
import 'package:store_management/l10n/app_localizations.dart';
import '../services/auth_service.dart'; // 👈 استدعاء ملف خدمة الاتصال بالسيرفر

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController =
      TextEditingController(); // تم تعديل الاسم ليتوافق مع الـ Backend (name)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  // 🛠️ تم تعديل الدالة بالكامل لتصبح Async وترسل البيانات فعلياً لقاعدة البيانات
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Conditions')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // 🚀 إرسال طلب الـ HTTP POST الفعلي إلى الـ Spring Boot
      bool isSuccess = await AuthService.register(name, email, password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès ! Connectez-vous.'),
            backgroundColor: Colors.green,
          ),
        );

        // التوجيه الفوري لصفحة تسجيل الدخول لكي يجرب بياناته الجديدة
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // رسالة تنبيه في حال فشل السيرفر أو أن البريد الإلكتروني مسجل مسبقاً
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Échec de l\'inscription. L\'email existe déjà ou le serveur est inaccessible.'),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // الخلفيات الزخرفية
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4361ee).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF27e0a9).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361ee),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4361ee).withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Icon(Icons.storefront,
                            size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'SMS Store',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191C1D)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Empowering retail entrepreneurs everywhere.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF444655)),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191C1D)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Join our community and grow your business today.',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF444655)),
                              ),
                              const SizedBox(height: 24),

                              // حقل الاسم الكامل
                              _buildFieldLabel('Full Name'),
                              TextFormField(
                                controller: _nameController,
                                decoration: _buildInputDecoration(
                                    'John Doe', Icons.person_outline),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter your name'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // حقل البريد الإلكتروني
                              _buildFieldLabel('Email Address'),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _buildInputDecoration(
                                    'name@company.com', Icons.mail_outline),
                                validator: (value) =>
                                    value == null || !value.contains('@')
                                        ? 'Please enter a valid email'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // حقل كلمة المرور
                              _buildFieldLabel('Password'),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: _buildInputDecoration(
                                        '••••••••', Icons.lock_outline)
                                    .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) => value == null ||
                                        value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // حقل تأكيد كلمة المرور
                              _buildFieldLabel('Confirm Password'),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscurePassword,
                                decoration: _buildInputDecoration(
                                    '••••••••', Icons.verified_user_outlined),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      activeColor: const Color(0xFF4361ee),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      onChanged: (val) => setState(
                                          () => _agreeToTerms = val ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'By signing up, I agree to the Terms of Service and Privacy Policy.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF444655),
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4361ee),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  onPressed:
                                      _isLoading ? null : _handleRegister,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Sign Up',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 18),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?',
                              style: TextStyle(
                                  color: Color(0xFF444655), fontSize: 14)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Sign In',
                                style: TextStyle(
                                    color: Color(0xFF4361ee),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const GridNavBanners(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF444655)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF747686), size: 22),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC4C5D7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4361ee), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class GridNavBanners extends StatelessWidget {
  const GridNavBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFeatureItem(Icons.flash_on, 'Fast Sync'),
        const SizedBox(width: 12),
        _buildFeatureItem(Icons.security, 'Secure Data'),
        const SizedBox(width: 12),
        _buildFeatureItem(Icons.bar_chart, 'Scalable'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF006C4F), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444655)),
            ),
          ],
        ),
      ),
    );
  }
}
