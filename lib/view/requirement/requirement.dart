import 'package:alora_admin/style/constant.dart';
import 'package:alora_admin/view/requirement/order_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: black,
          centerTitle: true,
          title: const Text('HOME'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final documents = snapshot.data?.docs.reversed.toList() ?? [];

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                final data = document.data() as Map<String, dynamic>?;

                List<dynamic>? requirements;
                if (data != null) {
                  if (data['userrequirement'] is List<dynamic>) {
                    requirements = data['userrequirement'] as List<dynamic>;
                  } else if (data['userrequirement'] is Map<String, dynamic>) {
                    requirements = [data['userrequirement']];
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: color1,
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            'Email ID: ${document.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Requirements: ${requirements?.length ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailsScreen(document),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
