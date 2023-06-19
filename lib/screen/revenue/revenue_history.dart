import 'package:alora_admin/style/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RevenueHistoryScreen extends StatefulWidget {
  @override
  _RevenueHistoryScreenState createState() => _RevenueHistoryScreenState();
}

class _RevenueHistoryScreenState extends State<RevenueHistoryScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _loadRevenueHistory();
  }

  void _loadRevenueHistory() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('revenue_history').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _historyData = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print('Error loading revenue history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revenue History'),
      ),
      body: ListView.builder(
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> history = _historyData[index];
          DateTime date = history['date'].toDate();

          return ListTile(
            title: Text('Date: ${date.day}/${date.month}/${date.year}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Revenue: \$${history['dailyRevenue']}'),
                Text('Weekly Revenue: \$${history['weeklyRevenue']}'),
                Text('Monthly Revenue: \$${history['monthlyRevenue']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
