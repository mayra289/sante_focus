import 'package:flutter/material.dart';

class AnalysesPage extends StatefulWidget {
  const AnalysesPage({super.key});

  @override
  State<AnalysesPage> createState() => _AnalysesPageState();
}

class _AnalysesPageState extends State<AnalysesPage> {
  final List<Map<String, dynamic>> _analyses = [
    {
      "patient": "Fatou Ndiaye",
      "type": "Bilan Sanguin",
      "date": "22/05/2024",
      "status": "Terminé",
      "result": "Normal",
      "color": Colors.green,
    },
    {
      "patient": "Moussa Traoré",
      "type": "Glycémie à jeun",
      "date": "21/05/2024",
      "status": "En attente",
      "result": "-",
      "color": Colors.orange,
    },
    {
      "patient": "Awa Diop",
      "type": "Analyse d'urine",
      "date": "20/05/2024",
      "status": "Terminé",
      "result": "Anomalie",
      "color": Colors.red,
    },
    {
      "patient": "Abdou Kane",
      "type": "Cholestérol",
      "date": "19/05/2024",
      "status": "Terminé",
      "result": "Normal",
      "color": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Résultats d'Analyses",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _analyses.length,
              itemBuilder: (context, index) => _buildAnalyseCard(_analyses[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnalyseDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_chart_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _buildSummaryItem("Total", "${_analyses.length}", Colors.blue),
          const SizedBox(width: 10),
          _buildSummaryItem("En attente", "1", Colors.orange),
          const SizedBox(width: 10),
          _buildSummaryItem("Anomalies", "1", Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyseCard(Map<String, dynamic> analyse) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: analyse['color'].withValues(alpha: 0.1),
          child: Icon(Icons.biotech_rounded, color: analyse['color']),
        ),
        title: Text(
          analyse['patient'], 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analyse['type'], 
              style: TextStyle(
                fontSize: 13, 
                color: Theme.of(context).textTheme.bodyMedium?.color
              )
            ),
            Text(
              "Date: ${analyse['date']}", 
              style: TextStyle(
                fontSize: 11, 
                color: Theme.of(context).textTheme.bodySmall?.color
              )
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: analyse['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(analyse['status'],
                  style: TextStyle(color: analyse['color'], fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Text(analyse['result'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: analyse['result'] == "Anomalie" ? Colors.red : (isDark ? Colors.grey : Colors.grey.shade700),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAddAnalyseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nouvelle Demande d'Analyse",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 20),
            _buildDialogField("Patient", Icons.person_outline),
            const SizedBox(height: 15),
            _buildDialogField("Type d'Analyse (ex: Bilan lipidique)", Icons.biotech_outlined),
            const SizedBox(height: 15),
            _buildDialogField("Instructions / Notes", Icons.note_alt_outlined),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("ENVOYER AU LABO",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
