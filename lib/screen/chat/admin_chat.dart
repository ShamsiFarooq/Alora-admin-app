import 'package:alora_admin/style/constant.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat'),
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

                  return ListTile(
                    title: FutureBuilder<String>(
                      future: fetchUserName(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final userName = snapshot.data!;
                          return Text(userName);
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
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
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
          userName: userName,
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

  UserChatScreen({required this.uid, required String userName});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('user'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesCollection
                  .where('sender', whereIn: [widget.uid])
                  .where('receiver', isEqualTo: [widget.uid])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // print(widget.uid);
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
                      return ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                decoration: const BoxDecoration(
                                  color: color5,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    message.sender + ': ' + message.message,
                                    style: const TextStyle(color: color1),
                                    overflow: TextOverflow.visible,
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
                        _textEditingController.text.trim(), widget.uid);
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
      await messagesCollection.add({
        'sender': "alora_admin",
        'receiver': uid,
        'message': message,
        'timestamp': DateTime.now(),
      });
    }
  }
}
