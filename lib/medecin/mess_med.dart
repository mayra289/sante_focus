import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_page.dart';

class DoctorMessagesPage extends StatelessWidget {
  const DoctorMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final medecinId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "Messagerie Médicale",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D47A1),
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: medecinId)
            .orderBy('dernierMessageDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data!.docs;
          if (conversations.isEmpty) {
            return const Center(
              child: Text("Aucune conversation pour le moment"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(15),
            children: conversations.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final participants = List<String>.from(
                data['participants'] ?? [],
              );
              final patientId = participants.firstWhere(
                (id) => id != medecinId,
                orElse: () => '',
              );
              final nomPatient = data['patientNom'] ?? 'Patient';
              final dernierMessage = data['dernierMessage'] ?? '';

              return _buildChatItem(
                context,
                conversationId: doc.id,
                patientId: patientId,
                name: nomPatient,
                message: dernierMessage.isEmpty
                    ? 'Nouvelle conversation'
                    : dernierMessage,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String conversationId,
    required String patientId,
    required String name,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatPage(conversationId: conversationId, otherUserName: name),
            ),
          );
        },
      ),
    );
  }
}
