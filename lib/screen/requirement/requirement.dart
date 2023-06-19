import 'package:alora_admin/style/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequirementScreen extends StatefulWidget {
  @override
  _RequirementScreenState createState() => _RequirementScreenState();
}

class _RequirementScreenState extends State<RequirementScreen> {
  String status = "";

  Stream<List<Map<String, dynamic>>> getUserRequirementsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> userRequirements = [];
      for (var doc in snapshot.docs) {
        final userRequirement = doc.data();
        final userRequirementsList =
            userRequirement['userrequirement'] as List<dynamic>;
        for (var requirement in userRequirementsList) {
          if (requirement is Map<String, dynamic>) {
            requirement['documentId'] = doc.id;
            userRequirements.add(requirement);
          }
        }
      }
      return userRequirements;
    });
  }

  void confirmRequirement(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to confirm?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(documentId)
                    .update({'status': 'Confirmed'})
                    .then((_) {})
                    .catchError((error) {});
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        // User confirmed
        setState(() {
          status = 'Confirmed';
        });
      }
    });
  }

  void cancelRequirement(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancellation',
          ),
          content: Text(
            'Are you sure you want to cancel?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'No',
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(documentId)
                    .update({'status': 'Cancelled'})
                    .then((_) {})
                    .catchError((error) {});
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        // User canceled
        setState(() {
          status = 'Cancelled';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        backgroundColor: color5,
        title: const Text('REQUIREMENT'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUserRequirementsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> userRequirements = snapshot.data!;
            return ListView.builder(
              itemCount: userRequirements.length,
              itemBuilder: (context, index) {
                final userRequirement = userRequirements[index];
                String documentId = userRequirement['documentId'];

                return Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color2,
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: ListTile(
                      title: Text(
                        'Contact Name: ${userRequirement['contactname']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: color5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height15,
                          Text(
                            'Date and Time: ${userRequirement['datetime']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Hours: ${userRequirement['hours']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Contact Number: ${userRequirement['contactnumber']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Location: ${userRequirement['location']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cleaning Type: ${userRequirement['cleaningtype']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Professionals: ${userRequirement['professional']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'User Id: ${userRequirement['documentId']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: color5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      confirmRequirement(documentId);
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
                                      cancelRequirement(documentId);
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
                                  SizedBox(height: 15),
                                ],
                              ),
                              Text(
                                status,
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
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
