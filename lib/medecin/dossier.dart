import 'package:flutter/material.dart';

class PatientDossierPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDossierPage({super.key, required this.patient});

  @override
  State<PatientDossierPage> createState() => _PatientDossierPageState();
}

class _PatientDossierPageState extends State<PatientDossierPage> {
  late Map<String, dynamic> medicalData;

  @override
  void initState() {
    super.initState();
    medicalData = {
      "vital": {"groupe": "O+", "taille": "1.75m", "poids": "72kg", "age": "28 ans"},
      "pathologies": ["Diabète Type 2", "Hypertension"],
      "famille": ["Père: Antécédents cardiaques", "Mère: Diabète"],
      "analyses": ["Glycémie: 0.95 g/L", "Cholestérol: 1.80 g/L"],
      "allergies": ["Pénicilline", "Arachides"],
      "traitements": ["Doliprane 1000mg", "Amoxicilline"],
      "habitudes": ["Sommeil: 6-7h", "Non-fumeur"],
      "historique": ["Chirurgie genou (2022)"],
    };
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("UNITÉ DE SOINS", 
              style: TextStyle(
                letterSpacing: 1.2, 
                fontSize: 10, 
                fontWeight: FontWeight.w800, 
                color: isDark ? Colors.white70 : Colors.white60
              )
            ),
            Text(widget.patient['name'].toUpperCase(), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_rounded, color: Colors.cyanAccent),
            onPressed: () => _notifyUpdate(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPatientMiniStats(primaryColor),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard("Constantes", Icons.monitor_heart, "vital", Colors.redAccent),
                  _buildMenuCard("Pathologies", Icons.assignment, "pathologies", Colors.orange),
                  _buildMenuCard("Médication", Icons.medication_liquid, "traitements", Colors.blue),
                  _buildMenuCard("Analyses", Icons.biotech, "analyses", Colors.purple),
                  _buildMenuCard("Allergies", Icons.gpp_maybe, "allergies", Colors.red),
                  _buildMenuCard("Antécédents", Icons.history, "historique", Colors.teal),
                  _buildMenuCard("Génétique", Icons.family_restroom, "famille", Colors.blueGrey),
                  _buildMenuCard("Mode de vie", Icons.spa, "habitudes", Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientMiniStats(Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniInfo("GROUPE", medicalData['vital']['groupe']),
          _miniInfo("ÂGE", medicalData['vital']['age']),
          _miniInfo("POIDS", medicalData['vital']['poids']),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, String key, Color color) {
    int count = key == "vital" ? 4 : (medicalData[key] as List).length;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _openSectionEditor(title, key, color),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14, 
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            const SizedBox(height: 4),
            Text(
              "$count entrées", 
              style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)
            ),
          ],
        ),
      ),
    );
  }

  void _openSectionEditor(String title, String key, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                  if (key != "vital")
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 30),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => _addNewEntry(key),
                    ),
                ],
              ),
            ),
            Expanded(
              child: key == "vital" ? _buildVitalEditor() : _buildListEditor(key, color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalEditor() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      children: medicalData['vital'].keys.map<Widget>((k) {
        return ListTile(
          title: Text(k.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
          subtitle: Text(medicalData['vital'][k], style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
          trailing: Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
          onTap: () => _editSingleField("Modifier $k", medicalData['vital'][k], (val) => setState(() => medicalData['vital'][k] = val)),
        );
      }).toList(),
    );
  }

  Widget _buildListEditor(String key, Color color) {
    List items = medicalData[key];
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: items.length,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        color: isDark ? Colors.grey.shade900 : const Color(0xFFF8F9FE),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: ListTile(
          title: Text(items[index], style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () => setState(() => items.removeAt(index)),
          ),
        ),
      ),
    );
  }

  void _addNewEntry(String key) {
    _editSingleField("Nouvelle entrée", "", (val) {
      setState(() => (medicalData[key] as List).add(val));
    });
  }

  void _editSingleField(String title, String initial, Function(String) onSave) {
    TextEditingController ctrl = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        content: TextField(
          controller: ctrl, 
          autofocus: true, 
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: const InputDecoration(border: OutlineInputBorder())
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () { onSave(ctrl.text); Navigator.pop(context); }, 
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: const Text("OK", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _notifyUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dossier mis à jour et synchronisé"), behavior: SnackBarBehavior.floating),
    );
  }
}
