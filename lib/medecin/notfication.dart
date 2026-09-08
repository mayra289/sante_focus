import 'package:flutter/material.dart';
import 'rdv_med.dart';
import 'mess_med.dart';
import 'analyse.dart';

class DoctorNotificationPage extends StatelessWidget {
  const DoctorNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Centre de Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, size: 20),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Toutes les notifications ont été marquées comme lues")),
              );
            },
            tooltip: "Tout marquer comme lu",
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader(context, "Aujourd'hui"),
          _buildNotificationItem(
            context: context,
            title: "Urgence : Patient Arrivé",
            subtitle: "Le patient Moussa Sow vient de signaler son arrivée en salle d'attente.",
            time: "Il y a 5 min",
            icon: Icons.emergency_share,
            color: Colors.red,
            isNew: true,
            onTap: () {
              // Action pour une urgence ou arrivée
            },
          ),
          _buildNotificationItem(
            context: context,
            title: "Nouvelle Demande de RDV",
            subtitle: "Awa Diagne souhaite un rendez-vous pour demain à 10:30.",
            time: "Il y a 15 min",
            icon: Icons.calendar_today_rounded,
            color: Colors.blue,
            isNew: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorAppointmentPage()));
            },
          ),
          _buildNotificationItem(
            context: context,
            title: "Résultats d'Analyse",
            subtitle: "Les résultats de biochimie de M. Fall sont disponibles.",
            time: "Il y a 1h",
            icon: Icons.biotech_rounded,
            color: Colors.green,
            isNew: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysesPage()));
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, "Hier"),
          _buildNotificationItem(
            context: context,
            title: "Message Patient",
            subtitle: "Mme Ndiaye a envoyé une question sur son traitement.",
            time: "Hier, 14:20",
            icon: Icons.chat_bubble_outline_rounded,
            color: Colors.purple,
            isNew: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorMessagesPage()));
            },
          ),
          _buildNotificationItem(
            context: context,
            title: "Mise à jour Système",
            subtitle: "SanteFocus a été mis à jour avec de nouvelles fonctionnalités.",
            time: "Hier, 09:00",
            icon: Icons.system_update_alt_rounded,
            color: Colors.grey,
            isNew: false,
            onTap: () {
              // Action info système
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodySmall?.color,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isNew,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNew 
          ? color.withValues(alpha: isDark ? 0.15 : 0.03) 
          : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: isNew ? Border.all(color: color.withValues(alpha: 0.2), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color
                )
              )
            ),
            if (isNew)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: TextStyle(
                fontSize: 13, 
                color: Theme.of(context).textTheme.bodyMedium?.color, 
                height: 1.3
              )
            ),
            const SizedBox(height: 6),
            Text(
              time, 
              style: TextStyle(
                fontSize: 11, 
                color: Theme.of(context).textTheme.bodySmall?.color, 
                fontWeight: FontWeight.w500
              )
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
