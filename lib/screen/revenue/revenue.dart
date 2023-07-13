import 'package:alora_admin/screen/revenue/revenue_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  double _totalRevenue = 0.0;
  double _dailyRevenue = 0.0;
  double _weeklyRevenue = 0.0;
  double _monthlyRevenue = 0.0;

  final TextEditingController _revenueController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  void _loadRevenueData() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('revenue').doc('office').get();
      if (snapshot.exists) {
        setState(() {
          _totalRevenue = snapshot['totalRevenue'] ?? 0.0;
          _dailyRevenue = snapshot['dailyRevenue'] ?? 0.0;
          _weeklyRevenue = snapshot['weeklyRevenue'] ?? 0.0;
          _monthlyRevenue = snapshot['monthlyRevenue'] ?? 0.0;
        });
      }
    } catch (e) {
      print('Error loading revenue data: $e');
    }
  }

  void _saveRevenueData() async {
    try {
      await _firestore.collection('revenue').doc('office').set({
        'totalRevenue': _totalRevenue,
        'dailyRevenue': _dailyRevenue,
        'weeklyRevenue': _weeklyRevenue,
        'monthlyRevenue': _monthlyRevenue,
      });
    } catch (e) {
      print('Error saving revenue data: $e');
    }
  }

  void _calculateRevenue() {
    double revenue = double.parse(_revenueController.text);
    double expenses = double.parse(_expensesController.text);

    setState(() {
      _totalRevenue = revenue - expenses;
      _dailyRevenue = _totalRevenue / 30;
      _weeklyRevenue = _totalRevenue / 4;
      _monthlyRevenue = _totalRevenue;
    });

    _saveRevenueData();
  }

  @override
  void dispose() {
    _revenueController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Revenue Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _revenueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Revenue',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _expensesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Expenses',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateRevenue,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total Revenue: \$$_totalRevenue',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Daily Revenue: \$$_dailyRevenue',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Weekly Revenue: \$$_weeklyRevenue',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Monthly Revenue: \$$_monthlyRevenue',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RevenueHistoryScreen()),
                );
              },
              child: const Text('View History'),
            ),
          ],
        ),
      ),
    );
  }
}
