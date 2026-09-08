import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  DateTime _selectedDate = DateTime.now();
  
  final List<Map<String, dynamic>> _events = [
    {"time": "08:00", "title": "Consultation", "patient": "Fatou Ndiaye", "type": "Urgent", "color": Colors.red},
    {"time": "09:30", "title": "Suivi Post-op", "patient": "Moussa Traoré", "type": "Normal", "color": Colors.blue},
    {"time": "11:00", "title": "Analyse Labo", "patient": "Awa Diop", "type": "Examen", "color": Colors.purple},
    {"time": "14:00", "title": "Réunion Staff", "patient": "Hôpital", "type": "Admin", "color": Colors.orange},
    {"time": "16:30", "title": "Consultation", "patient": "Abdou Kane", "type": "Normal", "color": Colors.blue},
  ];

  void _showAddEventDialog() {
    String title = "";
    String patient = "";
    String time = "08:00";
    String typeValue = "Normal";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nouvel Événement", 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            const SizedBox(height: 20),
            TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(labelText: "Titre"),
              onChanged: (v) => title = v,
            ),
            TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(labelText: "Patient / Lieu"),
              onChanged: (v) => patient = v,
            ),
            TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: const InputDecoration(labelText: "Heure (ex: 10:30)"),
              onChanged: (v) => time = v,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: typeValue,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              items: ["Normal", "Urgent", "Examen", "Admin"].map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (v) => typeValue = v!,
              decoration: const InputDecoration(labelText: "Catégorie"),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  if (title.isNotEmpty && patient.isNotEmpty) {
                    setState(() {
                      Color c = Colors.blue;
                      if(typeValue == "Urgent") c = Colors.red;
                      if(typeValue == "Examen") c = Colors.purple;
                      if(typeValue == "Admin") c = Colors.orange;

                      _events.add({
                        "time": time,
                        "title": title,
                        "patient": patient,
                        "type": typeValue,
                        "color": c,
                      });
                      _events.sort((a, b) => a['time'].compareTo(b['time']));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Ajouter au planning", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Mon Planning", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _events.length,
              itemBuilder: (context, index) => _buildEventCard(_events[index], index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", 
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary
                )
              ),
              Text("Date sélectionnée", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              event['time'], 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).textTheme.bodySmall?.color
              )
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border(left: BorderSide(color: event['color'], width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), 
                    blurRadius: 10
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'], 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color
                          )
                        ),
                        const SizedBox(height: 5),
                        Text(
                          event['patient'], 
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color, 
                            fontSize: 13
                          )
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => setState(() => _events.removeAt(index)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
