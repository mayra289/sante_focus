import 'package:flutter/material.dart';
import 'parametre.dart';
import 'notification.dart';
import 'patient/profil.dart';
import 'patient/dossier-med.dart';
import 'patient/ordonnance.dart';
import 'patient/medecins.dart';
import 'patient/vaccin.dart';
import 'patient/urgence.dart';
import 'patient/rdv.dart';
import 'patient/pharma.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _staggeredAnimations = List.generate(8, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 + (index * 0.05),
          0.6 + (index * 0.05),
          curve: Curves.easeOutCubic,
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _getPages() {
    return [
      _buildHomeContent(),
      const NotificationPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _getPages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
        unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              _controller.reset();
              _controller.forward();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: "Alertes"),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: "Paramètres"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildAnimatedHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _staggeredAnimations[0],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mes Services Santé",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Theme.of(context).textTheme.bodyLarge?.color
                          ),
                        ),
                        Icon(Icons.grid_view_rounded, color: Colors.blueAccent.withOpacity(0.3), size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.1,
                    children: [
                      _buildAnimatedMenuCard(0, "Dossier Médical", "assets/Acceuil/dossier.png", Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicalRecordPage()))),
                      _buildAnimatedMenuCard(1, "Ordonnances", "assets/Acceuil/ordonnance.png", Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrescriptionsPage()))),
                      _buildAnimatedMenuCard(2, "Mes Médecins", "assets/Acceuil/medecin.png", Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsPage()))),
                      _buildAnimatedMenuCard(3, "Messages", "assets/Acceuil/message.png", Colors.blueAccent, null),
                      _buildAnimatedMenuCard(4, "Vaccins", "assets/Acceuil/Vaccine.png", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VaccinePage()))),
                      _buildAnimatedMenuCard(5, "Urgences", "assets/Acceuil/urgence.png", Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyPage()))),
                      _buildAnimatedMenuCard(6, "Pharmacie", "assets/Acceuil/pharma.png", Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PharmacyPage()))),
                      _buildAnimatedMenuCard(7, "Rendez Vous", "assets/Acceuil/rendez-vous.png", Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentPage()))),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedMenuCard(int index, String title, String imagePath, Color color, VoidCallback? onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _staggeredAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _staggeredAnimations[index].value)),
          child: Opacity(
            opacity: _staggeredAnimations[index].value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : color.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 35,
                    width: 35,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.medical_services, color: color, size: 28),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 12, 
                    color: Theme.of(context).textTheme.bodyMedium?.color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _controller.value)),
          child: Opacity(
            opacity: _controller.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 35, left: 24, right: 24, bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12, 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logo_ispm.png', height: 40, width: 40, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.health_and_safety, color: Colors.blueAccent, size: 30)),
                Image.asset('assets/received_1527607458340717.jpeg', height: 40, width: 40, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.medical_services, color: Colors.blueAccent, size: 30)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                  },
                  child: _buildAvatarBadge(),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour 👋",
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                    ),
                    Text(
                      "Patient SanteFocus",
                      style: TextStyle(
                        color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 2),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(Icons.person_rounded, color: Colors.blue.shade700, size: 26),
      ),
    );
  }
}
