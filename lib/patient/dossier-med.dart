import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Comme il n'y a actuellement aucun formulaire pour saisir le dossier médical (ni côté patient ni côté médecin dans ce que vous m'avez montré),
//la section affichera "Aucune pathologie renseignée" etc.
//partout tant qu'il n'y a rien dans Firestore

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  bool _isLoading = true;
  String _nom = '';
  String _groupeSanguin = '--';
  String _taille = '--';
  String _poids = '--';
  String _age = '--';

  List<Map<String, dynamic>> _pathologies = [];
  List<Map<String, dynamic>> _antecedentsFamiliaux = [];
  List<Map<String, dynamic>> _analyses = [];
  List<Map<String, dynamic>> _allergies = [];
  List<Map<String, dynamic>> _traitements = [];
  List<Map<String, dynamic>> _habitudes = [];
  List<Map<String, dynamic>> _antecedentsMedicaux = [];

  @override
  void initState() {
    super.initState();
    _chargerDossier();
  }

  Future<void> _chargerDossier() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nom = data['nom'] ?? 'Patient';

      // calcul de l'âge à partir de dateNaissance (format jj/mm/aaaa)
      final dobStr = data['dateNaissance'] as String?;
      if (dobStr != null && dobStr.contains('/')) {
        final parts = dobStr.split('/');
        if (parts.length == 3) {
          final dob = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          final now = DateTime.now();
          int age = now.year - dob.year;
          if (now.month < dob.month ||
              (now.month == dob.month && now.day < dob.day))
            age--;
          _age = "$age ans";
        }
      }

      final dossier = data['dossierMedical'] as Map<String, dynamic>?;
      if (dossier != null) {
        _groupeSanguin = dossier['groupeSanguin'] ?? '--';
        _taille = dossier['taille'] ?? '--';
        _poids = dossier['poids'] ?? '--';
        _pathologies = List<Map<String, dynamic>>.from(
          dossier['pathologiesChroniques'] ?? [],
        );
        _antecedentsFamiliaux = List<Map<String, dynamic>>.from(
          dossier['antecedentsFamiliaux'] ?? [],
        );
        _analyses = List<Map<String, dynamic>>.from(dossier['analyses'] ?? []);
        _allergies = List<Map<String, dynamic>>.from(
          dossier['allergies'] ?? [],
        );
        _traitements = List<Map<String, dynamic>>.from(
          dossier['traitements'] ?? [],
        );
        _habitudes = List<Map<String, dynamic>>.from(
          dossier['habitudes'] ?? [],
        );
        _antecedentsMedicaux = List<Map<String, dynamic>>.from(
          dossier['antecedentsMedicaux'] ?? [],
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
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
          "Dossier Médical",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: isDark
            ? Colors.blue.shade300
            : const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientSummary(context),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Informations Vitales",
              Icons.favorite_rounded,
            ),
            _buildVitalInfoCard(context),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Pathologies Chroniques",
              Icons.assignment_late_outlined,
            ),
            _buildDynamicCard(
              context,
              _pathologies,
              Icons.emergency_outlined,
              Colors.orange,
              "Aucune pathologie renseignée",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Antécédents Familiaux",
              Icons.family_restroom_rounded,
            ),
            _buildDynamicCard(
              context,
              _antecedentsFamiliaux,
              Icons.family_restroom,
              Colors.blueGrey,
              "Aucun antécédent renseigné",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Dernières Analyses",
              Icons.analytics_outlined,
            ),
            _buildDynamicCard(
              context,
              _analyses,
              Icons.science_outlined,
              Colors.purple,
              "Aucune analyse renseignée",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Allergies & Contre-indications",
              Icons.warning_amber_rounded,
            ),
            _buildDynamicCard(
              context,
              _allergies,
              Icons.block,
              Colors.red,
              "Aucune allergie renseignée",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Traitements en cours",
              Icons.medication_rounded,
            ),
            _buildDynamicCard(
              context,
              _traitements,
              Icons.medical_services,
              Colors.blue,
              "Aucun traitement en cours",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Habitudes & Sommeil",
              Icons.hotel_rounded,
            ),
            _buildDynamicCard(
              context,
              _habitudes,
              Icons.bedtime_outlined,
              Colors.indigo,
              "Aucune habitude renseignée",
            ),
            const SizedBox(height: 25),

            _buildSectionTitle(
              context,
              "Antécédents Médicaux",
              Icons.history_edu_rounded,
            ),
            _buildDynamicCard(
              context,
              _antecedentsMedicaux,
              Icons.content_paste_search,
              Colors.teal,
              "Aucun antécédent renseigné",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSummary(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
              : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Âge : $_age",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _VitalItem(
            label: "Groupe",
            value: _groupeSanguin,
            icon: Icons.bloodtype,
            color: Colors.red,
          ),
          _VitalItem(
            label: "Taille",
            value: _taille,
            icon: Icons.height,
            color: Colors.blue,
          ),
          _VitalItem(
            label: "Poids",
            value: _poids,
            icon: Icons.monitor_weight,
            color: Colors.green,
          ),
          _VitalItem(
            label: "Âge",
            value: _age,
            icon: Icons.cake,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCard(
    BuildContext context,
    List<Map<String, dynamic>> items,
    IconData icon,
    Color color,
    String messageVide,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Text(
          messageVide,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 13,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => _buildListTile(
                context,
                icon,
                item['titre'] ?? '',
                item['details'] ?? '',
                color,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _VitalItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
