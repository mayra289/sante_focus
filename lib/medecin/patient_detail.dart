import 'package:flutter/material.dart';
import 'consultation.dart';

class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Informations Personnelles"),
                  _buildInfoCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Contact d'Urgence"),
                  _buildEmergencyContact(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Résumé Médical Rapide"),
                  _buildMedicalSummary(),
                  const SizedBox(height: 100), // Espace pour le bouton
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0D47A1),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(patient['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF0D47A1), const Color(0xFF0D47A1).withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Text(patient['name'][0], style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text("ID: ${patient['id'] ?? 'SF-2024-001'}", style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionBtn(Icons.phone, "Appeler", Colors.green),
        _buildActionBtn(Icons.message, "Message", Colors.blue),
        _buildActionBtn(Icons.videocam, "Visio", Colors.purple),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInfoRow(Icons.cake, "Âge / Sexe", "${patient['age']} / ${patient['gender']}"),
          const Divider(height: 30),
          _buildInfoRow(Icons.location_on, "Adresse", "Dakar, Liberté 6 Extension"),
          const Divider(height: 30),
          _buildInfoRow(Icons.email, "Email", "patient@email.com"),
          const Divider(height: 30),
          _buildInfoRow(Icons.phone_android, "Téléphone", patient['phone'] ?? "Non renseigné"),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade100)),
      child: const Row(
        children: [
          Icon(Icons.contact_emergency, color: Colors.red),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mme Ndiaye (Épouse)", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("+221 77 000 00 00", style: TextStyle(color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMedicalSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildSummaryItem("Groupe Sanguin", "O+", Colors.red),
          _buildSummaryItem("Pathologie actuelle", patient['pathology'] ?? "Aucune", Colors.orange),
          _buildSummaryItem("Dernière Tension", patient['tension'] ?? "N/A", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ConsultationPage(patient: patient)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("DÉMARRER CONSULTATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
