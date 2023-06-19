import 'package:alora_admin/style/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChat extends StatefulWidget {
  @override
  _AdminChatState createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              String userName = users[index].data() is Map<String, dynamic>
                  ? (users[index].data() as Map<String, dynamic>)['name'] ?? ''
                  : '';

              return ListTile(
                title: Text(userName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(userName: userName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final String? userName;

  ChatDetailPage({this.userName});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // Save the message to the database
      FirebaseFirestore.instance.collection('messages').add({
        'sender': 'Admin',
        'recipient': widget.userName,
        'text': messageText,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('recipient', isEqualTo: widget.userName)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic>? data =
                        messages[index].data() as Map<String, dynamic>?;
                    String sender = '';
                    String text = '';

                    if (data != null) {
                      sender = data['sender'] ?? '';
                      text = data['text'] ?? '';
                    }

                    return ListTile(
                      title: Text(
                        sender,
                        style: TextStyle(color: color2, fontSize: 18),
                      ),
                      subtitle: Text(
                        text,
                        style: TextStyle(color: color1, fontSize: 16),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
