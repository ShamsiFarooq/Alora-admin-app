import 'package:alora_admin/style/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const OrderDetailsScreen(this.document, {super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Map<String, dynamic>> requirements = [];

  void confirmRequirement(String documentId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to confirm?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final DocumentSnapshot docSnapshot = await FirebaseFirestore
                      .instance
                      .collection('orders')
                      .doc(documentId)
                      .get();

                  if (docSnapshot.exists) {
                    final Map<String, dynamic>? docData =
                        docSnapshot.data() as Map<String, dynamic>?;

                    final List<dynamic> customerRequirements =
                        docData?['userrequirement'] ?? [];

                    if (index >= 0 && index < customerRequirements.length) {
                      customerRequirements[index]['status'] = 'confirmed';

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(documentId)
                          .update({'userrequirement': customerRequirements});

                      setState(() {
                        requirements =
                            customerRequirements.cast<Map<String, dynamic>>();
                      });
                    }
                  }
                } catch (error) {
                  // Handle error
                  print(error.toString());
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        // User confirmed
        if (index >= 0 && index < requirements.length) {
          setState(() {
            requirements[index]['status'] = 'Confirmed';
          });
        }
      }
    });
  }

  void cancelRequirement(String documentId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancellation'),
          content: const Text('Are you sure you want to cancel?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final DocumentSnapshot docSnapshot = await FirebaseFirestore
                      .instance
                      .collection('orders')
                      .doc(documentId)
                      .get();

                  if (docSnapshot.exists) {
                    final Map<String, dynamic>? docData =
                        docSnapshot.data() as Map<String, dynamic>?;

                    final List<dynamic> customerRequirements =
                        docData?['userrequirement'] ?? [];

                    if (index >= 0 && index < customerRequirements.length) {
                      customerRequirements[index]['status'] = 'Cancelled';

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(documentId)
                          .update({'userrequirement': customerRequirements});

                      setState(() {
                        requirements =
                            customerRequirements.cast<Map<String, dynamic>>();
                      });
                    }
                  }
                } catch (error) {
                  // Handle error
                  print(error.toString());
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        // User canceled
        if (index >= 0 && index < requirements.length) {
          setState(() {
            requirements[index]['status'] = 'Cancelled';
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>?;
    requirements = data?['userrequirement']?.cast<Map<String, dynamic>>() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: color1,
        appBar: AppBar(
          backgroundColor: black,
          title: const Text('Order Details'),
          centerTitle: true,
        ),
        body: ListView.builder(
          reverse: true,
          itemCount: requirements.length,
          itemBuilder: (context, index) {
            final requirement = requirements[index];

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: black,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Requirement ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: color1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      height15,
                      Text(
                        'Contact Number: ${requirement['contactname']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Contact Number: ${requirement['contactnumber']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Date and Time: ${requirement['date']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Date and Time: ${requirement['time']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Hours: ${requirement['hours']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Location: ${requirement['location']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Cleaning Type: ${requirement['cleanigtype']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'Professionals: ${requirement['professional']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      Text(
                        'User Id: ${requirement['documentId']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height5,
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print(index);
                                  confirmRequirement(
                                    requirement['documentId'],
                                    index,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'CONFIRM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print(index);

                                  cancelRequirement(
                                    requirement['documentId'],
                                    index,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                          Text(
                            requirement['status'] ?? 'Pending status',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
