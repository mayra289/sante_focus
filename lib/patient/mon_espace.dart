import 'package:flutter/material.dart';

class MyPatientSpacePage extends StatelessWidget {
  const MyPatientSpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthCard(context),
                  const SizedBox(height: 25),
                  _buildSectionTitle(context, "Mes Prochains RDV"),
                  _buildNextAppointment(context),
                  const SizedBox(height: 25),
                  _buildSectionTitle(context, "Mes Documents Récents"),
                  _buildDocumentList(context),
                  const SizedBox(height: 25),
                  _buildSectionTitle(context, "Ma Santé en Chiffres"),
                  _buildHealthStats(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? Colors.blueGrey.shade900 : const Color(0xFF0D47A1),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("Mon Espace Santé", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Colors.blueGrey.shade900, Colors.black] 
                : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
            child: const Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Patient SanteFocus", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const Text("Groupe sanguin: O+", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                Text("ID: SF-2024-001", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.qr_code_2_rounded, size: 30, color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1)),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }

  Widget _buildNextAppointment(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1);
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade800.withOpacity(0.3) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text("15", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)),
                Text("MAI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. Valisoa", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text("Cardiologie - 10:30", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: primaryColor),
        ],
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    return Column(
      children: [
        _buildDocItem(context, "Ordonnance", "12/05/2024", Icons.description, Colors.orange),
        _buildDocItem(context, "Résultat d'analyse", "10/05/2024", Icons.science, Colors.purple),
      ],
    );
  }

  Widget _buildDocItem(BuildContext context, String title, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color))),
          Text(date, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(width: 10),
          const Icon(Icons.download_rounded, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildHealthStats(BuildContext context) {
    return Row(
      children: [
        _buildStatBox(context, "Tension", "12/8", "Normal", Colors.green),
        const SizedBox(width: 10),
        _buildStatBox(context, "Poids", "72kg", "-2kg", Colors.blue),
        const SizedBox(width: 10),
        _buildStatBox(context, "Glycémie", "0.95", "Normal", Colors.teal),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
            Text(sub, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
