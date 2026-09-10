import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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
  bool _isSendingImage = false;

  void _envoyerMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final texte = _controller.text.trim();
    _controller.clear();

    final convoRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId);
    await convoRef.collection('messages').add({
      'senderId': _currentUserId,
      'type': 'texte',
      'texte': texte,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await convoRef.update({
      'dernierMessage': texte,
      'dernierMessageDate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _envoyerImage() async {
    final picker = ImagePicker();
    final XFile? fichier = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (fichier == null) return;

    setState(() => _isSendingImage = true);
    try {
      final Uint8List bytes = await fichier.readAsBytes();

      // Décoder et redimensionner l'image pour rester sous la limite Firestore (1 Mo)
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception("Image invalide");

      img.Image resized = img.copyResize(
        image,
        width: 800,
      ); // largeur max 800px
      final compressedBytes = img.encodeJpg(
        resized,
        quality: 50,
      ); // compression forte

      final base64Image = base64Encode(compressedBytes);

      // Sécurité : si malgré la compression c'est encore trop gros, on refuse
      if (base64Image.length > 700000) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Image trop volumineuse, réessayez avec une autre photo",
            ),
          ),
        );
        return;
      }

      final convoRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId);
      await convoRef.collection('messages').add({
        'senderId': _currentUserId,
        'type': 'image',
        'imageData': base64Image,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await convoRef.update({
        'dernierMessage': '📷 Photo',
        'dernierMessageDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      if (mounted) setState(() => _isSendingImage = false);
    }
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
                    final type = data['type'] ?? 'texte';

                    return Align(
                      alignment: estMoi
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: type == 'image'
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: estMoi
                              ? const Color(0xFF0D47A1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: type == 'image'
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(data['imageData']),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
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
                  IconButton(
                    icon: _isSendingImage
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image_outlined),
                    onPressed: _isSendingImage ? null : _envoyerImage,
                  ),
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
