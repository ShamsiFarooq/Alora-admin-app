import 'dart:convert';

import 'package:alora_admin/style/constant.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

String generateChatRoomId(String adminId, String userId) {
  final ids = [adminId, userId];
  ids.sort(); // Sort the IDs to ensure consistent chat room IDs
  final concatenatedIds = ids.join('_');
  final bytes = utf8.encode(concatenatedIds);
  final hash = sha1.convert(bytes);
  return hash.toString();
}

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

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
    final userName = await fetchUserName(userId);
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

class ChatMessage {
  final String sender;
  final String message;

  ChatMessage({required this.sender, required this.message});
}

class UserChatScreen extends StatefulWidget {
  final String uid;
  final String adminId = 'alora_admin'; // Set the admin ID

  UserChatScreen({required this.uid});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  String chatRoomId = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    getChatRoomId();
    fetchUsername();
  }

  void getChatRoomId() {
    chatRoomId = generateChatRoomId(widget.adminId, widget.uid);
  }

  Future<void> fetchUsername() async {
    final userSnapshot = await userCollection.doc(widget.uid).get();
    final userData = userSnapshot.data() as Map<String, dynamic>?;
    setState(() {
      username = userData?['username'] ?? 'Unknown User';
    });
  }

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(username),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesCollection
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return ChatMessage(
                      sender: data['sender'],
                      message: data['message'],
                    );
                  }).toList();

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final bool isAdmin = message.sender == widget.adminId;
                      final bool isCurrentUser = message.sender == widget.uid;
                      final containerColor =
                          isAdmin ? Colors.green : Colors.blue;
                      final alignment = isCurrentUser
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: alignment,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: isCurrentUser
                                        ? Radius.circular(15)
                                        : Radius.zero,
                                    topLeft: isAdmin
                                        ? Radius.circular(15)
                                        : Radius.zero,
                                    bottomRight: isCurrentUser
                                        ? Radius.zero
                                        : Radius.circular(15),
                                    bottomLeft: isAdmin
                                        ? Radius.zero
                                        : Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: userCollection
                                        .doc(message.sender)
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.exists) {
                                          final userData =
                                              snapshot.data!.data();
                                          if (userData != null &&
                                              userData
                                                  is Map<String, dynamic>) {
                                            final senderName =
                                                (userData['username'] != null)
                                                    ? userData['username']
                                                    : (isCurrentUser
                                                        ? 'You'
                                                        : 'Admin');

                                            return Text(
                                              '$senderName: ${message.message}',
                                              style: const TextStyle(
                                                  color: color1),
                                              overflow: TextOverflow.visible,
                                            );
                                          }
                                        }
                                      }
                                      return Text(
                                        message.sender + ': ' + message.message,
                                        style: const TextStyle(color: color1),
                                        overflow: TextOverflow.visible,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const CircularProgressIndicator();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter Message',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(
                      _textEditingController.text.trim(),
                      widget.uid,
                    );
                    _textEditingController.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message, String uid) async {
    if (message.isNotEmpty) {
      await messagesCollection.doc(chatRoomId).collection('messages').add({
        'sender': widget.adminId,
        'receiver': uid,
        'message': message,
        'timestamp': DateTime.now(),
      });
    }
  }
}
