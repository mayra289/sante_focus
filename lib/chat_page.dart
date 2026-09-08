import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _envoyerMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final texte = _controller.text.trim();
    _controller.clear();

    final convoRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId);
    await convoRef.collection('messages').add({
      'senderId': _currentUserId,
      'texte': texte,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await convoRef.update({
      'dernierMessage': texte,
      'dernierMessageDate': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(
                    child: Text("Aucun message. Dites bonjour !"),
                  );
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final estMoi = data['senderId'] == _currentUserId;
                    return Align(
                      alignment: estMoi
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: estMoi
                              ? const Color(0xFF0D47A1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['texte'] ?? '',
                          style: TextStyle(
                            color: estMoi ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _envoyerMessage,
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
