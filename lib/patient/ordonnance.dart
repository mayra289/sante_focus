import 'package:flutter/material.dart';

class PrescriptionsPage extends StatelessWidget {
  const PrescriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Mes Ordonnances",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildArchiveTitle(context, "Ordonnances Récentes"),
                _buildPrescriptionCard(
                  context,
                  "Dr. Jean Dupont",
                  "Généraliste",
                  "15 Mai 2024",
                  "En cours",
                  Colors.green,
                ),
                _buildPrescriptionCard(
                  context,
                  "Dr. Sarah Mansour",
                  "Cardiologue",
                  "02 Mai 2024",
                  "Terminée",
                  Colors.grey,
                ),
                const SizedBox(height: 20),
                _buildArchiveTitle(context, "Archives (2023)"),
                _buildPrescriptionCard(
                  context,
                  "Dr. Alice Ndiaye",
                  "Dentiste",
                  "20 Déc. 2023",
                  "Terminée",
                  Colors.grey,
                ),
                _buildPrescriptionCard(
                  context,
                  "Dr. Jean Dupont",
                  "Généraliste",
                  "10 Nov. 2023",
                  "Terminée",
                  Colors.grey,
                ),
                _buildPrescriptionCard(
                  context,
                  "Dr. Moussa Sow",
                  "Ophtalmologue",
                  "15 Sept. 2023",
                  "Terminée",
                  Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Theme.of(context).cardColor,
      child: TextField(
        readOnly: true,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: "Rechercher une ordonnance...",
          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildArchiveTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, String doctor,
      String specialty, String date, String status, Color statusColor) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              Icon(Icons.description_outlined, color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1)),
        ),
        title: Text(doctor,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialty,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 5),
                Text(date,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionDetailPage(
                doctor: doctor,
                specialty: specialty,
                date: date,
                status: status,
                statusColor: statusColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PrescriptionDetailPage extends StatelessWidget {
  final String doctor;
  final String specialty;
  final String date;
  final String status;
  final Color statusColor;

  const PrescriptionDetailPage({
    super.key,
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Détails de l'ordonnance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        foregroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person_rounded,
                      size: 40, color: primaryColor),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text(specialty,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 40),

            _buildInfoRow(context, Icons.calendar_month, "Date de prescription", date),
            _buildInfoRow(context, Icons.info_outline, "Statut", status,
                textColor: statusColor),

            const SizedBox(height: 30),
            Text("Médicaments & Instructions",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryColor)),
            const SizedBox(height: 15),

            _buildMedicationItem(context, "Paracétamol 500mg",
                "1 comprimé, 3 fois par jour pendant 5 jours"),
            _buildMedicationItem(context, "Amoxicilline 1g",
                "1 gélule matin et soir au milieu des repas"),
            _buildMedicationItem(context, 
                "Sirop Toplexil", "1 mesure, soir au coucher si toux"),

            const SizedBox(height: 30),
            Text("Note du médecin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 10),
            Text(
              "Reposez-vous bien et buvez beaucoup d'eau. Revenir me voir si la fièvre persiste après 3 jours.",
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 40),
            
            // Bouton Télécharger Ordonnance
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Téléchargement de l'ordonnance en cours... ✅")),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("Télécharger en PDF", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Center(
              child: Text(
                "Document numérique certifié par SanteFocus",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value,
      {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label : ", style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, String name, String instruction) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.blueGrey.shade800 : Colors.blue.withOpacity(0.1)),
        boxShadow: isDark ? [BoxShadow(color: Colors.black12, blurRadius: 5)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 4),
          Text(instruction,
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
