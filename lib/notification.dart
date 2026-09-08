import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openMap(String address) async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmMedication(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Confirmer la prise", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text("Avez-vous pris votre dose de $name ?", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Non")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Prise de $name enregistrée ✅")),
              );
            },
            child: const Text("Oui, c'est fait", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Alertes & Rappels",
          style: TextStyle(color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Toutes les notifications ont été marquées comme lues")),
              );
            },
            tooltip: "Tout marquer comme lu",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Santé", icon: Icon(Icons.medication_outlined)),
            Tab(text: "RDV", icon: Icon(Icons.calendar_today_rounded)),
            Tab(text: "Général", icon: Icon(Icons.notifications_none_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationTab(),
          _buildAppointmentsTab(),
          _buildGeneralTab(),
        ],
      ),
    );
  }

  Widget _buildMedicationTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("À prendre maintenant"),
        _buildAlertCard(
          title: "Doliprane 1000mg",
          subtitle: "1 gélule - Après le repas",
          time: "08:00",
          icon: Icons.access_time_filled,
          color: Colors.redAccent,
          isUrgent: true,
          onTap: () => _confirmMedication("Doliprane 1000mg"),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader("Prochaines prises"),
        _buildAlertCard(
          title: "Amoxicilline",
          subtitle: "2 comprimés",
          time: "13:00",
          icon: Icons.medication,
          color: Colors.blueAccent,
          onTap: () => _confirmMedication("Amoxicilline"),
        ),
        _buildAlertCard(
          title: "Vitamine C",
          subtitle: "1 sachet effervescent",
          time: "19:00",
          icon: Icons.wb_sunny_outlined,
          color: Colors.orange,
          onTap: () => _confirmMedication("Vitamine C"),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Rendez-vous confirmés"),
        _buildAlertCard(
          title: "Dr. Mamadou Ndiaye",
          subtitle: "Cardiologue - Clinique de la Paix",
          time: "Demain, 10:30",
          icon: Icons.person_search,
          color: Colors.indigo,
          actionLabel: "Voir itinéraire",
          onTap: () => _openMap("Clinique de la Paix, Dakar"),
        ),
        _buildAlertCard(
          title: "Analyse de Sang",
          subtitle: "Laboratoire Bio-Santé",
          time: "Vendredi, 07:45",
          icon: Icons.science_outlined,
          color: Colors.teal,
          actionLabel: "Préparations",
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).cardColor,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Préparations pour Analyse", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 15),
                    Text("• Être à jeun depuis au moins 8 heures.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    Text("• Éviter les exercices physiques intenses la veille.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    Text("• Boire uniquement de l'eau plate.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("J'ai compris", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Notifications récentes"),
        _buildGeneralNotification(
          "Mise à jour Dossier",
          "Votre carnet de vaccination a été mis à jour par l'administration.",
          "Il y a 2 heures",
          Icons.update,
          Colors.blueGrey,
        ),
        _buildGeneralNotification(
          "Conseil Santé",
          "Pensez à boire au moins 1.5L d'eau aujourd'hui vu la chaleur.",
          "Il y a 5 heures",
          Icons.lightbulb_outline,
          Colors.amber,
        ),
        _buildGeneralNotification(
          "Sécurité",
          "Nouvelle connexion à votre compte depuis un appareil Android.",
          "Hier",
          Icons.security,
          Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    bool isUrgent = false,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isUrgent ? Border.all(color: color.withOpacity(0.5), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          time,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (isUrgent)
                          const Icon(Icons.priority_high, color: Colors.redAccent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        actionLabel,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralNotification(String title, String body, String date, IconData icon, Color color) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dismissible(
      key: Key(title + date),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification supprimée")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Text(date, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
