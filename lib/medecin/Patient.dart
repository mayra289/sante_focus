import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dossier.dart';
import 'consultation.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _allPatients = [
    {
      "id": "SF-2024-001",
      "name": "Fatou Ndiaye",
      "age": "28 ans",
      "gender": "F",
      "phone": "+221 77 123 45 67",
      "lastVisit": "12 Mai 2024",
      "status": "Suivi régulier",
      "pathology": "Asthme / HTA",
      "tension": "12/8",
      "temp": "37.2°C",
      "color": Colors.pink.shade50,
      "groupe": "O+",
      "taille": "1.65m",
      "poids": "62kg",
    },
    {
      "id": "SF-2024-042",
      "name": "Moussa Traoré",
      "age": "45 ans",
      "gender": "M",
      "phone": "+221 70 987 65 43",
      "lastVisit": "10 Mai 2024",
      "status": "Urgent",
      "pathology": "Diabète Type 2",
      "tension": "14/9",
      "temp": "38.5°C",
      "color": Colors.blue.shade50,
      "groupe": "A+",
      "taille": "1.80m",
      "poids": "85kg",
    },
    {
      "id": "SF-2024-015",
      "name": "Awa Diop",
      "age": "32 ans",
      "gender": "F",
      "phone": "+221 76 555 44 33",
      "lastVisit": "08 Mai 2024",
      "status": "Stable",
      "pathology": "Post-opératoire",
      "tension": "11/7",
      "temp": "36.8°C",
      "color": Colors.teal.shade50,
      "groupe": "B-",
      "taille": "1.70m",
      "poids": "68kg",
    },
  ];

  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      _filteredPatients = _allPatients
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              user["id"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lancer l'appel")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ma Patientèle",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTopStats(),
          _buildSearchBox(),
          Expanded(
            child: _filteredPatients.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) =>
                        _buildPatientClinicalCard(_filteredPatients[index]),
                  )
                : const Center(
                    child: Text("Aucun patient trouvé",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildTopStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatItem("Patients", "${_allPatients.length}", Colors.blue),
          const SizedBox(width: 12),
          _buildStatItem("Urgents", "${_allPatients.where((p) => p['status'] == 'Urgent').length}", Colors.red),
          const SizedBox(width: 12),
          _buildStatItem("Nouveaux", "2", Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: "Rechercher par nom ou ID dossier...",
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                _runFilter("");
              })
            : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildPatientClinicalCard(Map<String, dynamic> patient) {
    bool isUrgent = patient['status'] == "Urgent";
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUrgent ? Border.all(color: Colors.red.shade200, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDossierPage(patient: patient)));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: patient['color'],
                    child: Text(
                      patient['name'][0], 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary
                      )
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['name'], 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color
                          )
                        ),
                        Text(
                          "ID: ${patient['id']} • ${patient['age']}", 
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color, 
                            fontSize: 12
                          )
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(patient['status']),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: isDark ? Colors.grey.shade800 : const Color(0xFFF0F0F0)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildClinicalInfo(Icons.medical_services_outlined, "Pathologie", patient['pathology']),
                  _buildClinicalInfo(Icons.favorite_outline, "Tension", patient['tension']),
                  _buildClinicalInfo(Icons.thermostat_outlined, "Temp.", patient['temp']),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(patient['phone']),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text("Contacter", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => ConsultationPage(patient: patient)));
                      },
                      icon: const Icon(Icons.add_task, size: 16, color: Colors.white),
                      label: const Text("Consulter", style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Theme.of(context).colorScheme.primary;
    if (status == "Urgent") color = Colors.red;
    if (status == "Stable") color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildClinicalInfo(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color
          )
        ),
      ],
    );
  }

  void _showAddPatientDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nouveau Dossier Patient", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary
                )
              ),
              const SizedBox(height: 20),
              _buildDialogField("Nom Complet", Icons.person_outline),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDialogField("Âge", Icons.cake_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDialogField("Sexe (M/F)", Icons.people_outline)),
                ],
              ),
              const SizedBox(height: 15),
              _buildDialogField("Téléphone", Icons.phone_outlined),
              const SizedBox(height: 15),
              Text(
                "Données Vitales", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color
                )
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDialogField("Groupe Sang.", Icons.bloodtype_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDialogField("Taille (m)", Icons.height)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDialogField("Poids (kg)", Icons.monitor_weight_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDialogField("Tension (mmHg)", Icons.favorite_outline)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDialogField("Température (°C)", Icons.thermostat_outlined)),
                  const SizedBox(width: 10),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 15),
              _buildDialogField("Pathologies Chroniques", Icons.assignment_late_outlined),
              const SizedBox(height: 15),
              _buildDialogField("Allergies", Icons.warning_amber_rounded),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("CRÉER LE DOSSIER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, IconData icon) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
