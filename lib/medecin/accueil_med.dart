import 'package:flutter/material.dart';
import '../parametre.dart';
import 'notfication.dart';
import 'rdv_med.dart';
import 'Patient.dart';
import 'ordo.dart';
import 'dossier.dart';
import 'consultation.dart';
import 'profil_med.dart';
import 'planning.dart';
import 'analyse.dart';
import 'statistique.dart';
import 'mess_med.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with SingleTickerProviderStateMixin {
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

    _staggeredAnimations = List.generate(12, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.05 + (index * 0.05),
          0.55 + (index * 0.05),
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
      const DoctorNotificationPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _getPages()[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 
        ? FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: _controller,
              child: FloatingActionButton.extended(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationPage(patient: {"name": "Nouveau Patient", "age": "N/A", "id": "SF-NEW", "color": Colors.blue})));
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Nouvelle Consultation", style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Paramètres"),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedSection(0, _buildSearchBar()),
                  const SizedBox(height: 25),
                  _buildAnimatedSection(1, _buildStatsRow()),
                  const SizedBox(height: 30),
                  _buildAnimatedSection(2, Text(
                    "Gestion Médicale Complète",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  )),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildAnimatedMenuCard(3, "Mes RDV", Icons.event_available, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorAppointmentPage()))),
                      _buildAnimatedMenuCard(4, "Mes Patients", Icons.people_outline, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientsPage()))),
                      _buildAnimatedMenuCard(5, "Consultations", Icons.medical_services_outlined, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationPage(patient: {"name": "Patient en attente", "age": "N/A", "id": "SF-000", "color": Colors.orange})))),
                      _buildAnimatedMenuCard(6, "Ordonnances", Icons.history_edu, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorPrescriptionsPage()))),
                      _buildAnimatedMenuCard(7, "Dossiers", Icons.folder_copy_outlined, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientsPage()))),
                      _buildAnimatedMenuCard(8, "Planning", Icons.access_time_rounded, Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanningPage()))),
                      _buildAnimatedMenuCard(9, "Analyses", Icons.biotech_rounded, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysesPage()))),
                      _buildAnimatedMenuCard(10, "Messages", Icons.chat_bubble_outline_rounded, Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorMessagesPage()))),
                      _buildAnimatedMenuCard(11, "Statistiques", Icons.bar_chart_rounded, Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage()))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggeredAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _staggeredAnimations[index].value)),
          child: Opacity(
            opacity: _staggeredAnimations[index].value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAnimatedMenuCard(int index, String title, IconData icon, Color color, VoidCallback onTap) {
    return _buildAnimatedSection(index, Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color
                )
              ),
            ],
          ),
        ),
      ),
    ));
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
        padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour,",
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                    ),
                    Text(
                      "Dr. Valisoa",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileMedPage())),
                  child: _buildAvatarBadge(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: const InputDecoration(
          hintText: "Rechercher un patient...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard("En attente", "5", Icons.hourglass_empty, Colors.orange),
        const SizedBox(width: 15),
        _buildStatCard("Terminés", "3/8", Icons.check_circle_outline, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
    );
  }
}
