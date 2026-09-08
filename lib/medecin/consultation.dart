import 'package:flutter/material.dart';
import 'ordo.dart';

class ConsultationPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ConsultationPage({super.key, required this.patient});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final TextEditingController _symptomesController = TextEditingController();
  final TextEditingController _diagnosticController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Consultation en cours", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPatientMiniCard(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Constantes du jour"),
                  _buildConstantesForm(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Motif & Symptômes"),
                  _buildLargeTextField(_symptomesController, "Décrivez les symptômes rapportés...", 3),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Diagnostic"),
                  _buildLargeTextField(_diagnosticController, "Conclusion médicale...", 2),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Notes privées"),
                  _buildLargeTextField(_notesController, "Notes complémentaires...", 2),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientMiniCard() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: widget.patient['color'] ?? Colors.blue.shade100,
            child: Text(
              widget.patient['name'][0], 
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
                  widget.patient['name'], 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color
                  )
                ),
                Text(
                  "Dossier: ${widget.patient['id'] ?? 'N/A'} • ${widget.patient['age']}", 
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
            onPressed: () {},
            tooltip: "Historique",
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title, 
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).textTheme.bodyLarge?.color
        )
      ),
    );
  }

  Widget _buildConstantesForm() {
    return Row(
      children: [
        _buildSmallInput("Tension", "12/8", "mmHg"),
        const SizedBox(width: 10),
        _buildSmallInput("Temp.", "37.5", "°C"),
        const SizedBox(width: 10),
        _buildSmallInput("Poids", "70", "kg"),
      ],
    );
  }

  Widget _buildSmallInput(String label, String hint, String unit) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: Colors.grey.shade800) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
            TextField(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                suffixText: unit,
                suffixStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeTextField(TextEditingController controller, String hint, int lines) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.grey.shade800) : null,
      ),
      child: TextField(
        controller: controller,
        maxLines: lines,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.all(15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorPrescriptionsPage()));
            },
            icon: const Icon(Icons.medication_liquid_rounded, color: Colors.white),
            label: const Text("Rédiger une Ordonnance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Consultation enregistrée avec succès"), behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("TERMINER LA CONSULTATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
