import 'package:flutter/material.dart';
import 'consultation.dart';

class DoctorAppointmentPage extends StatefulWidget {
  const DoctorAppointmentPage({super.key});

  @override
  State<DoctorAppointmentPage> createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  List<Map<String, dynamic>> todayAppointments = [
    {"time": "09:00", "patient": "Fatou Ndiaye", "type": "Consultation générale", "color": Colors.blue, "isDone": true, "id": "SF-001"},
    {"time": "10:30", "patient": "Moussa Traoré", "type": "Suivi traitement", "color": Colors.teal, "isDone": false, "id": "SF-042"},
    {"time": "11:15", "patient": "Awa Diop", "type": "Urgence", "color": Colors.red, "isDone": false, "id": "SF-015"},
  ];

  List<Map<String, dynamic>> upcomingAppointments = [
    {"date": "Demain - 15 Mai", "time": "08:30", "patient": "Paul Valéry", "type": "Contrôle annuel", "color": Colors.blue},
    {"date": "Jeudi - 16 Mai", "time": "09:15", "patient": "Albert Camus", "type": "Suivi", "color": Colors.teal},
  ];

  List<Map<String, dynamic>> appointmentRequests = [
    {"patient": "Ousmane Sonko", "info": "Demande pour le 18 Mai, 10:00", "reason": "Douleurs abdominales"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Gestion des RDV", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: "Aujourd'hui"),
            Tab(text: "À venir"),
            Tab(text: "Demandes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildUpcomingTab(),
          _buildRequestsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: todayAppointments.length,
      itemBuilder: (context, index) {
        return _buildTimeSlot(todayAppointments[index], index, isToday: true);
      },
    );
  }

  Widget _buildUpcomingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        return _buildTimeSlot(upcomingAppointments[index], index, isUpcoming: true);
      },
    );
  }

  Widget _buildRequestsTab() {
    if (appointmentRequests.isEmpty) {
      return Center(
        child: Text(
          "Aucune demande en attente",
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointmentRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(appointmentRequests[index], index);
      },
    );
  }

  Widget _buildTimeSlot(Map<String, dynamic> rdv, int index, {bool isToday = false, bool isUpcoming = false}) {
    bool isDone = rdv['isDone'] ?? false;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), 
            blurRadius: 5
          )
        ],
      ),
      child: ListTile(
        onTap: isToday ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConsultationPage(patient: rdv)));
        } : null,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rdv['time'], 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isDone ? Colors.grey : Theme.of(context).colorScheme.primary
              )
            ),
            if (isDone) const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
        title: Text(
          rdv['patient'], 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        subtitle: Text(
          rdv['type'], 
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color
          )
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
          onSelected: (value) {
            setState(() {
              if (value == 'done') rdv['isDone'] = !isDone;
              if (value == 'delete') {
                if (isToday) todayAppointments.removeAt(index);
                else upcomingAppointments.removeAt(index);
                _showSnackbar("Rendez-vous annulé");
              }
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'done', child: Text(isDone ? "Réactiver" : "Marquer comme terminé")),
            const PopupMenuItem(value: 'delete', child: Text("Annuler", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), 
            blurRadius: 5
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request['patient'], 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color
            )
          ),
          Text(
            request['info'], 
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color, 
              fontSize: 12
            )
          ),
          const SizedBox(height: 10),
          Text(
            "Motif: ${request['reason']}", 
            style: TextStyle(
              fontStyle: FontStyle.italic, 
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color
            )
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => appointmentRequests.removeAt(index));
                    _showSnackbar("Demande refusée", isError: true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Refuser", style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final req = appointmentRequests.removeAt(index);
                      upcomingAppointments.add({
                        "date": "Confirmé",
                        "time": "À définir",
                        "patient": req['patient'],
                        "type": "Nouveau RDV",
                        "color": Colors.blue
                      });
                    });
                    _showSnackbar("Rendez-vous accepté");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Accepter", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Nouveau Rendez-vous", 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _patientController, 
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(labelText: "Nom du patient", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _typeController, 
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(labelText: "Motif", prefixIcon: Icon(Icons.medical_services)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    todayAppointments.add({
                      "time": "14:00",
                      "patient": _patientController.text,
                      "type": _typeController.text,
                      "color": Colors.blue,
                      "isDone": false
                    });
                  });
                  Navigator.pop(context);
                  _showSnackbar("Rendez-vous enregistré");
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
