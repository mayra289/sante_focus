import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_page.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  String _selectedFilter = "Tous";
  bool _isLoading = true;
  List<Map<String, dynamic>> _allDoctors = [];

  @override
  void initState() {
    super.initState();
    _chargerMedecins();
  }

  Future<void> _chargerMedecins() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('medecins')
        .get();
    _allDoctors = snapshot.docs.map((d) {
      final data = d.data();
      return {
        "id": d.id,
        "name": data['nom'] ?? 'Médecin',
        "specialty": data['specialite'] ?? 'Généraliste',
        "exp": data['experience'] ?? 'Expérience non renseignée',
        "loc": data['lieuExercice'] ?? 'Lieu non renseigné',
        "status": data['statut'] ?? 'Disponible',
        "color": (data['statut'] == 'Indisponible')
            ? Colors.red
            : (data['statut'] == 'En consultation')
            ? Colors.orange
            : Colors.green,
      };
    }).toList();
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_selectedFilter == "Tous") {
      return _allDoctors;
    }
    return _allDoctors
        .where(
          (doc) => doc["specialty"].toString().contains(
            _selectedFilter.substring(0, _selectedFilter.length - 1),
          ),
        )
        .toList();
  }

  Future<void> _demarrerConversation(
    BuildContext context,
    String medecinId,
    String medecinNom,
  ) async {
    final patientId = FirebaseAuth.instance.currentUser!.uid;
    final conversationId = patientId.compareTo(medecinId) < 0
        ? "${patientId}_$medecinId"
        : "${medecinId}_$patientId";

    final convoRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId);
    final doc = await convoRef.get();
    if (!doc.exists) {
      await convoRef.set({
        'participants': [patientId, medecinId],
        'medecinNom': medecinNom,
        'dernierMessage': '',
        'dernierMessageDate': FieldValue.serverTimestamp(),
      });
    }
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatPage(conversationId: conversationId, otherUserName: medecinNom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Nos Médecins",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: isDark
            ? Colors.blue.shade300
            : const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: _allDoctors.isEmpty
                ? const Center(
                    child: Text("Aucun médecin disponible pour le moment"),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSectionTitle(context, "Médecins Disponibles"),
                      const SizedBox(height: 10),
                      ..._filteredDoctors.map(
                        (doc) => _buildDoctorCard(context, doc),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            readOnly: true,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: "Rechercher un médecin ou une spécialité...",
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.blue.shade300 : Colors.grey,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip("Tous"),
                _buildFilterChip("Généralistes"),
                _buildFilterChip("Cardiologues"),
                _buildFilterChip("Dentistes"),
                _buildFilterChip("Pédiatres"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _selectedFilter == label;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doc) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDoctorDetails(context, doc),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.person_3_rounded,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            doc["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (doc["color"] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              doc["status"],
                              style: TextStyle(
                                color: doc["color"],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc["specialty"],
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            doc["loc"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDoctorDetails(BuildContext context, Map<String, dynamic> doc) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person_3_rounded,
                    size: 50,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc["name"],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        doc["specialty"],
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            _buildInfoDetail(
              context,
              Icons.location_on_rounded,
              "Lieu d'exercice",
              doc["loc"],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // ferme le bottom sheet
                  _demarrerConversation(context, doc["id"], doc["name"]);
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text("Contacter ce médecin"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDetail(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
