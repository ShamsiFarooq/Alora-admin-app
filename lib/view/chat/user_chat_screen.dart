import 'package:alora_admin/model/chat_message.dart';
import 'package:alora_admin/services/chat_room_id.dart';
import 'package:alora_admin/style/constant.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
