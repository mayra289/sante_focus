import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedConsultationType = "Générale";
  String? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      _showTimePicker(context, picked);
    }
  }

  Future<void> _showTimePicker(BuildContext context, DateTime date) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      final formattedTime = picked.format(context);
      _showSnackbar("Demande de modification envoyée pour le $formattedDate à $formattedTime");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Rendez-vous",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: primaryColor,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: "Mes Rendez-vous"),
            Tab(text: "Prendre RDV"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyAppointmentsTab(context),
          _buildBookAppointmentTab(context),
        ],
      ),
    );
  }

  Widget _buildMyAppointmentsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionTitle(context, "À venir"),
        const SizedBox(height: 15),
        _buildAppointmentCard(
          context,
          "Dr. Sarah Mansour",
          "Cardiologue",
          "Demain, 10:30",
          "Hôpital Principal",
          Colors.blueAccent,
          true,
        ),
        _buildAppointmentCard(
          context,
          "Dr. Jean Dupont",
          "Généraliste",
          "12 Juin, 14:00",
          "Clinique de l'Espoir",
          Colors.green,
          true,
        ),
        const SizedBox(height: 30),
        _buildSectionTitle(context, "Historique"),
        const SizedBox(height: 15),
        _buildAppointmentCard(
          context,
          "Dr. Alice Ndiaye",
          "Dentiste",
          "20 Mai, 09:15",
          "Cabinet Dentaire Pro",
          Colors.grey,
          false,
        ),
      ],
    );
  }

  Widget _buildBookAppointmentTab(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Réservez une consultation en quelques clics",
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 25),
          _buildStepTitle(context, "1. Choisir le type de consultation"),
          const SizedBox(height: 15),
          _buildConsultationTypeGrid(context),
          const SizedBox(height: 30),
          _buildStepTitle(context, "2. Sélectionner un médecin disponible"),
          const SizedBox(height: 15),
          _buildDoctorSelectionList(context),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _selectedDoctor == null 
                ? null 
                : () => _showBookingSuccessDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("VÉRIFIER LES DISPONIBILITÉS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  Widget _buildStepTitle(BuildContext context, String title) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1)),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, String doctor, String specialty, String time, String location, Color color, bool isUpcoming) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          if (isUpcoming) _showCancelAppointmentDialog(context, doctor);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.calendar_today_rounded, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text(specialty, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(time, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(location, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ],
              ),
            ),
            if (isUpcoming)
              const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCancelAppointmentDialog(BuildContext context, String doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Options du rendez-vous", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined, color: Colors.blue),
              title: Text("Modifier la date", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
                _selectDate(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text("Annuler le rendez-vous", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar("Demande d'annulation envoyée pour le RDV avec $doctor");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationTypeGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 2.5,
      children: [
        _buildTypeChip(context, "Générale", Icons.medical_services),
        _buildTypeChip(context, "Spécialisée", Icons.biotech),
        _buildTypeChip(context, "Dentaire", Icons.biotech),
        _buildTypeChip(context, "Contrôle", Icons.visibility),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String label, IconData icon) {
    bool isSelected = _selectedConsultationType == label;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1);
    
    return InkWell(
      onTap: () => setState(() => _selectedConsultationType = label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSelectionList(BuildContext context) {
    return Column(
      children: [
        _buildDoctorMiniCard(context, "Dr. Sarah Mansour", "Cardiologue", "Prochaine dispo: Aujourd'hui"),
        _buildDoctorMiniCard(context, "Dr. Jean Dupont", "Généraliste", "Prochaine dispo: Demain"),
      ],
    );
  }

  Widget _buildDoctorMiniCard(BuildContext context, String name, String specialty, String availability) {
    bool isSelected = _selectedDoctor == name;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1);
    
    return InkWell(
      onTap: () => setState(() => _selectedDoctor = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade200), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text(specialty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(availability, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Radio<String>(
              value: name, 
              groupValue: _selectedDoctor, 
              onChanged: (value) => setState(() => _selectedDoctor = value),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
            SizedBox(height: 15),
            Text("Recherche en cours", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Nous recherchons les meilleurs créneaux pour vous. Vous recevrez une notification de confirmation.", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
              _showSnackbar("Votre demande de RDV a été envoyée !");
            },
            child: Text("COMPRIS", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
