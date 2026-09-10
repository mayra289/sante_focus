import 'package:flutter/material.dart';

class DoctorPrescriptionsPage extends StatefulWidget {
  const DoctorPrescriptionsPage({super.key});

  @override
  State<DoctorPrescriptionsPage> createState() =>
      _DoctorPrescriptionsPageState();
}

class _DoctorPrescriptionsPageState extends State<DoctorPrescriptionsPage> {
  final List<Map<String, dynamic>> _prescriptions = [
    {
      "patient": "Fatou Ndiaye",
      "date": "12 Mai 2024",
      "medicines": ["Paracétamol 1g", "Amoxicilline 500mg"],
      "advice": "Bien s'hydrater et se reposer.",
      "status": "Délivré",
    },
    {
      "patient": "Moussa Traoré",
      "date": "10 Mai 2024",
      "medicines": ["Metformine 850mg"],
      "advice": "Éviter les aliments trop sucrés.",
      "status": "En attente",
    },
  ];

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPrescriptionDialog({int? index}) {
    final bool isEditing = index != null;
    final nameController = TextEditingController(
      text: isEditing ? _prescriptions[index]['patient'] : "",
    );
    final medController = TextEditingController(
      text: isEditing ? _prescriptions[index]['medicines'].join(', ') : "",
    );
    final adviceController = TextEditingController(
      text: isEditing ? (_prescriptions[index]['advice'] ?? "") : "",
    );
    String statusValue = isEditing
        ? _prescriptions[index]['status']
        : "En attente";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            isEditing ? "Modifier l'Ordonnance" : "Nouvelle Ordonnance",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Nom du Patient",
                  ),
                ),
                TextField(
                  controller: medController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Médicaments (virgules)",
                  ),
                ),
                TextField(
                  controller: adviceController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: const InputDecoration(labelText: "Conseils"),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: statusValue,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: const InputDecoration(labelText: "Statut"),
                  items: ["En attente", "Délivré"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => statusValue = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    medController.text.isNotEmpty) {
                  setState(() {
                    final data = {
                      "patient": nameController.text,
                      "date": isEditing
                          ? _prescriptions[index]['date']
                          : "Aujourd'hui",
                      "medicines": medController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                      "advice": adviceController.text,
                      "status": statusValue,
                    };
                    if (isEditing) {
                      _prescriptions[index] = data;
                    } else {
                      _prescriptions.insert(0, data);
                    }
                  });
                  Navigator.pop(context);
                  _showSnackbar(
                    isEditing ? "Ordonnance mise à jour" : "Ordonnance ajoutée",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                isEditing ? "Enregistrer" : "Ajouter",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Gestion des Ordonnances",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
      ),
      body: _prescriptions.isEmpty
          ? Center(
              child: Text(
                "Aucune ordonnance",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _prescriptions.length,
              itemBuilder: (context, index) {
                final ordo = _prescriptions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ordo['patient'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            ordo['date'],
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        "Médicaments: ${ordo['medicines'].join(', ')}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      if (ordo['advice'] != null &&
                          ordo['advice'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Conseils: ${ordo['advice']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(ordo['status']),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _showPrescriptionDialog(index: index),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.print,
                                  size: 20,
                                  color: isDark ? Colors.grey : Colors.blueGrey,
                                ),
                                onPressed: () => _showSnackbar(
                                  "Impression de l'ordonnance de ${ordo['patient']}...",
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _prescriptions.removeAt(index);
                                  });
                                  _showSnackbar("Ordonnance supprimée");
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPrescriptionDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == "Délivré" ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
