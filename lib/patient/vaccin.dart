import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  bool _isLoading = true;
  int patientAge = 0;
  List<Map<String, dynamic>> _vaccinsEffectues = [];

  bool get isChild => patientAge < 15;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1. Calcul de l'âge réel à partir du profil patient
    final patientDoc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .get();
    final dobStr = patientDoc.data()?['dateNaissance'] as String?;
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
        patientAge = age;
      }
    }

    // 2. Récupération des vaccins réellement enregistrés
    final vaccinsSnap = await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .collection('vaccins')
        .orderBy('date', descending: true)
        .get();

    _vaccinsEffectues = vaccinsSnap.docs.map((d) => d.data()).toList();

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "Carnet de Vaccination",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(),
              const SizedBox(height: 25),

              _buildSectionTitle(
                "Vaccins Effectués (Obligatoires)",
                Icons.verified_user_rounded,
                Colors.green,
              ),
              const SizedBox(height: 12),
              ..._vaccinsEffectues.map(
                (v) => _buildVaccineItem(
                  v['nom'] ?? '',
                  "Fait le ${v['date'] ?? '--'}",
                  v['lieu'] ?? '',
                  true,
                  false,
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                "Prochains Vaccins / Rappels",
                Icons.pending_actions_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              ..._getPendingVaccines().map(
                (v) => _buildVaccineItem(
                  v['title'],
                  v['subtitle'],
                  v['place'],
                  false,
                  v['isOptional'] ?? false,
                ),
              ),

              const SizedBox(height: 30),
              _buildInfoBox(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCompletedVaccines() {
    if (isChild) {
      return [
        {
          "title": "BCG (Tuberculose)",
          "subtitle": "Fait à la naissance",
          "place": "Maternité Hôpital",
          "isOptional": false,
        },
        {
          "title": "VPO-0 (Polio orale)",
          "subtitle": "Fait à la naissance",
          "place": "Maternité Hôpital",
          "isOptional": false,
        },
        {
          "title": "Hépatite B - Naissance",
          "subtitle": "Fait à la naissance",
          "place": "Maternité Hôpital",
          "isOptional": false,
        },
        {
          "title": "Penta 1 (DTC-HepB-Hib)",
          "subtitle": "Fait à 6 semaines",
          "place": "Centre de Santé",
          "isOptional": false,
        },
        {
          "title": "Pneumo 1",
          "subtitle": "Fait à 6 semaines",
          "place": "Centre de Santé",
          "isOptional": false,
        },
        {
          "title": "Rotavirus 1",
          "subtitle": "Fait à 6 semaines",
          "place": "Centre de Santé",
          "isOptional": false,
        },
        {
          "title": "Penta 2",
          "subtitle": "Fait à 10 semaines",
          "place": "Centre de Santé",
          "isOptional": false,
        },
        {
          "title": "VPO-1 & Pneumo 2",
          "subtitle": "Fait à 10 semaines",
          "place": "Centre de Santé",
          "isOptional": false,
        },
      ];
    } else {
      return [
        {
          "title": "Hépatite B (Schéma complet)",
          "subtitle": "Fait en 2015",
          "place": "Institut Pasteur",
          "isOptional": false,
        },
        {
          "title": "Fièvre Jaune",
          "subtitle": "Fait le 12/05/2021",
          "place": "Centre de Vaccination",
          "isOptional": false,
        },
        {
          "title": "Tétanos (VAT)",
          "subtitle": "Dernier rappel 2022",
          "place": "Infirmerie",
          "isOptional": false,
        },
        {
          "title": "COVID-19 (3 doses)",
          "subtitle": "Terminé en 2022",
          "place": "Centre de Santé",
          "isOptional": true,
        },
      ];
    }
  }

  List<Map<String, dynamic>> _getPendingVaccines() {
    if (isChild) {
      return [
        {
          "title": "Penta 3 & VPO-3",
          "subtitle": "Prévu à 14 semaines",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "VPI (Polio injectable)",
          "subtitle": "Prévu à 14 semaines",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Rougeole-Rubéole 1",
          "subtitle": "Prévu à 9 mois",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Fièvre Jaune",
          "subtitle": "Prévu à 9 mois",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Méningite A",
          "subtitle": "Prévu à 9 mois",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Rougeole-Rubéole 2",
          "subtitle": "Prévu à 15 mois",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Varicelle",
          "subtitle": "Conseillé après 12 mois",
          "place": "Facultatif",
          "isOptional": true,
        },
        {
          "title": "Hépatite A",
          "subtitle": "Conseillé après 12 mois",
          "place": "Facultatif",
          "isOptional": true,
        },
        {
          "title": "Méningocoque B",
          "subtitle": "Selon recommandation",
          "place": "Facultatif",
          "isOptional": true,
        },
      ];
    } else {
      return [
        {
          "title": "Grippe Saisonnière",
          "subtitle": "Conseillé (Annuel)",
          "place": "Pharmacie",
          "isOptional": true,
        },
        {
          "title": "Fièvre Typhoïde",
          "subtitle": "Recommandé (Voyages/Risques)",
          "place": "Centre de Vaccination",
          "isOptional": true,
        },
        {
          "title": "HPV (Papillomavirus)",
          "subtitle": "Si non vacciné(e) jeune",
          "place": "Centre de Gynécologie",
          "isOptional": true,
        },
        {
          "title": "Rappel Tétanos (VAT)",
          "subtitle": "Prochain en 2032",
          "place": "À planifier",
          "isOptional": false,
        },
        {
          "title": "Méningocoque ACWY",
          "subtitle": "Recommandé (Voyages)",
          "place": "Facultatif",
          "isOptional": true,
        },
      ];
    }
  }

  Widget _buildStatCard() {
    double progress = isChild ? 0.5 : 0.8;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isChild
              ? [const Color(0xFF00BFA5), const Color(0xFF1DE9B6)]
              : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChild
                ? "Suivi PEV (Programme Élargi de Vaccination)"
                : "Suivi Immunitaire Adulte",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            isChild
                ? "Bébé SanteFocus ($patientAge ans)"
                : "Patient Adulte ($patientAge ans)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
          Text(
            "${(progress * 100).toInt()}% du calendrier obligatoire complété",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineItem(
    String title,
    String subtitle,
    String place,
    bool isDone,
    bool isOptional,
  ) {
    Color mainColor = isDone
        ? Colors.green
        : (isOptional ? Colors.blueAccent : Colors.orange);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mainColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : (isOptional
                        ? Icons.info_outline_rounded
                        : Icons.calendar_today_rounded),
              color: mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isOptional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "FACULTATIF",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  place,
                  style: TextStyle(
                    color: mainColor.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.blueAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isChild
                  ? "Le calendrier PEV est obligatoire. Les vaccins facultatifs (Varicelle, HepA) sont recommandés pour une protection élargie."
                  : "Les vaccins obligatoires dépendent de la réglementation locale et des voyages. Les vaccins optionnels (Grippe, Typhoïde) renforcent votre sécurité.",
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
