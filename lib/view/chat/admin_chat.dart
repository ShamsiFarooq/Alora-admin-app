import 'package:alora_admin/model/chat_message.dart';
import 'package:alora_admin/style/constant.dart';
import 'package:alora_admin/view/chat/user_chat_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // ignore: unused_field
  final TextEditingController _textEditingController = TextEditingController();
  List<String> userIds = [];
  Map<String, List<ChatMessage>> userMessages = {};
  String selectedUserId = '';

  @override
  void initState() {
    super.initState();
    fetchUserIds();
  }

  Future<void> fetchUserIds() async {
    final snapshot = await usersCollection.get();
    setState(() {
      userIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<String> fetchUserName(String uid) async {
    final snapshot = await usersCollection.doc(uid).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return data['username'];
  }

  Future<List<ChatMessage>> fetchUserMessages(String userId) async {
    final snapshot = await messagesCollection
        .where('sender', whereIn: [userId, 'alora_admin'])
        .where('receiver', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ChatMessage(
        sender: data['sender'],
        message: data['message'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: color5,
          title: const Text('Customers'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: userIds.length,
                  itemBuilder: (context, index) {
                    final userId = userIds[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(29),
                        ),
                        child: ListTile(
                          title: FutureBuilder<String>(
                            future: fetchUserName(userId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userName = snapshot.data!;
                                return Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          onTap: () {
                            _openChatRoom(
                              userId,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openChatRoom(String userId) async {
    //final userName = await fetchUserName(userId);
    setState(() {
      selectedUserId = userId;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserChatScreen(
          uid: userId,
        ),
      ),
    );
  }
}
