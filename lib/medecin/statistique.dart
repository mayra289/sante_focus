import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tableau de Bord & Stats",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStats(),
            const SizedBox(height: 25),
            Text("Activité Hebdomadaire",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 15),
            _buildWeeklyChart(),
            const SizedBox(height: 25),
            Text("Répartition des Pathologies",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 15),
            _buildPathologyStats(),
            const SizedBox(height: 25),
            _buildPatientGrowthCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Row(
      children: [
        _statCard("124", "Patients Total", Icons.people, Colors.blue),
        const SizedBox(width: 15),
        _statCard("42", "Consultations/Mois", Icons.calendar_today, Colors.green),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
              blurRadius: 10
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(
              value, 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(0.4, "Lun"),
              _bar(0.7, "Mar"),
              _bar(0.5, "Mer"),
              _bar(0.9, "Jeu"),
              _bar(0.6, "Ven"),
              _bar(0.2, "Sam"),
              _bar(0.1, "Dim"),
            ],
          ),
          const Divider(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 16),
              SizedBox(width: 5),
              Text("+12% par rapport à la semaine dernière",
                  style: TextStyle(fontSize: 11, color: Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  Widget _bar(double height, String day) {
    return Column(
      children: [
        Container(
          height: 100 * height,
          width: 15,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPathologyStats() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          _pathologyRow("Diabète", 0.45, Colors.orange),
          const SizedBox(height: 15),
          _pathologyRow("HTA", 0.30, Colors.red),
          const SizedBox(height: 15),
          _pathologyRow("Asthme", 0.15, Colors.blue),
          const SizedBox(height: 15),
          _pathologyRow("Autres", 0.10, Colors.grey),
        ],
      ),
    );
  }

  Widget _pathologyRow(String name, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name, 
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
            Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: color.withValues(alpha: 0.1),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildPatientGrowthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary, 
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
          ]
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.insights, color: Colors.white, size: 40),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Croissance Patientèle",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Vous avez accueilli 8 nouveaux patients ce mois-ci.",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
