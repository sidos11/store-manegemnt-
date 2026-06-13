import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// ✅ Import des vraies screens premium
import '../screens/product_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;

  String userName = "Chargement...";
  String userEmail = "Email...";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload =
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final Map<String, dynamic> tokenData = jsonDecode(payload);
          setState(() {
            userEmail = tokenData['sub'] ?? 'Utilisateur';
            userName = userEmail.split('@')[0].toUpperCase();
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = "Utilisateur";
        userEmail = "Erreur de chargement";
      });
    }
  }

  // ✅ CORRECTION PRINCIPALE : les vraies screens à la place des placeholders vides
  late final List<Widget> _screens = [
    const ReportsScreen(), // index 0 — Dashboard → Reports (KPI Bento)
    const SalesScreenModern(), // index 1 — Sales
    const ProductScreen(), // index 2 — Products (Grid premium)
    const SizedBox.shrink(), // index 3 — Profile (géré dans le body)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA).withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDEE1FF),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDkQ9HOucrIjJapVTqsw9S7Q3xFi8_8o2AcqmuE37X71feNHcXf0UohHWrPdCVGnvj-u_6ec8IraAL3PgT24NgSNGRtVJ20I-TrhmURtworNikCdh5vzfWTaGZAMp8i2g4LtEX6owRbrUQvaHYiw1bfcBlvfQcADT2rSt9YKbsLuB6aTtMrH1tjFHk4IdxWuYnpa6pDZAIUigzLaE5j_H1YAc09q_2rBk5VeYfffVzYCARSiyefIkBU3pZzz5KohJIQIoz4G51-bHYf',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: Color(0xFF2346D5)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SMS Store',
              style: TextStyle(
                color: Color(0xFF2346D5),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF191C1D)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ✅ Body : affiche la bonne screen selon l'onglet sélectionné
      body: _currentIndex != 3
          ? _screens[_currentIndex]
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Account Management'),
                      const SizedBox(height: 8),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          subtitle: 'Update your name and address',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.security,
                          title: 'Security & Password',
                          subtitle: '2FA, Password management',
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage SMS and Email alerts',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Store Settings'),
                      const SizedBox(height: 8),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.payments_outlined,
                          title: 'Payout Settings',
                          subtitle: 'Bank details and payment logs',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.help_center_outlined,
                          title: 'Help & Support',
                          subtitle: 'Get help with your store',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFDAD6).withOpacity(0.2),
                            side: const BorderSide(
                                color: Color(0xFFBA1A1A), width: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            foregroundColor: const Color(0xFFBA1A1A),
                          ),
                          onPressed: () async {
                            bool isLoggedOut = await AuthService.logout();
                            if (isLoggedOut && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Déconnexion réussie ! À bientôt.'),
                                  backgroundColor: Colors.blueGrey,
                                ),
                              );
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            }
                          },
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'App Version 2.4.0 (Enterprise-Lite)',
                          style:
                              TextStyle(color: Color(0xFF747686), fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

      // Bottom Navigation Bar (inchangée)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2346D5),
          unselectedItemColor: const Color(0xFF444655),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_outlined),
              activeIcon: Icon(Icons.point_of_sale),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF747686),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  color: const Color(0xFFEDEEEF),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDML9DwAcCaDjRaud31YMG9zErbstaovZdKnKdQEVwqtbrX0AqGrm1xXUxLMS0mmwJtwSvI0G4atD5lNS3W734G8ebzV6yM5k3uS4Io5nvPUzSRT_-PUXp5ECRZ--ktsjLODXxv1PUXyoIMfxC0Tt4DaI1mXdLOKBf9cdzov6sKiUCgh7oJOsIckC5sAoJnF4cgDwf_XC6xwj44xVDRD0VqpFNbAzq8s34EljXi2vqAKSDhGW2BoTzP6o-xUE9Nw2w7Y8q5L4AMKCUD',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF747686)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2346D5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C1D)),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: const TextStyle(fontSize: 14, color: Color(0xFF444655)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF51FAC1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Color(0xFF007152), size: 14),
                SizedBox(width: 4),
                Text(
                  'Verified Store Owner',
                  style: TextStyle(
                      color: Color(0xFF007152),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEEF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2346D5), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF191C1D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF444655)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF747686)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Color(0xFFC4C5D7), height: 1, thickness: 0.3),
    );
  }
}
