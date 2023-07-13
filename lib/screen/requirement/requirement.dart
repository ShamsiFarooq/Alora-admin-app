import 'package:alora_admin/style/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequirementScreen extends StatefulWidget {
  @override
  _RequirementScreenState createState() => _RequirementScreenState();
}

class _RequirementScreenState extends State<RequirementScreen> {
  String status = "";
  List<Map<String, dynamic>> userRequirements = [];

  Stream<List<Map<String, dynamic>>> getUserRequirementsStream() {
    return FirebaseFirestore.instance
        .collection('orders')
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
            requirement['userId'] = doc.id;

            userRequirements.add(requirement);
          }
        }
      }
      return userRequirements;
    });
  }

  void confirmRequirement(String documentId, int index) {
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
                    for (var requirement in customerRequirements) {
                      if (requirement['documentId'] == documentId) {
                        requirement['status'] = 'Confirmed';
                        break;
                      }
                    }
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(documentId)
                        .update({'userrequirement': customerRequirements});

                    for (var i = 0; i < userRequirements.length; i++) {
                      if (userRequirements[i]['documentId'] == documentId) {
                        setState(() {
                          userRequirements[i]['status'] = 'Confirmed';
                        });
                        break;
                      }
                    }
                  }
                } catch (error) {
                  // Handle error
                  print(error.toString());
                }
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
        if (index >= 0 && index < userRequirements.length) {
          setState(() {
            userRequirements[index]['status'] = 'Confirmed';
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
          title: Text('Cancellation'),
          content: Text('Are you sure you want to cancel?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
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
                    for (var requirement in customerRequirements) {
                      if (requirement['documentId'] == documentId) {
                        requirement['status'] = 'Cancelled';
                        break;
                      }
                    }
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(documentId)
                        .update({'userrequirement': customerRequirements});

                    for (var i = 0; i < userRequirements.length; i++) {
                      if (userRequirements[i]['documentId'] == documentId) {
                        setState(() {
                          userRequirements[i]['status'] = 'Cancelled';
                        });
                        break;
                      }
                    }
                  }
                } catch (error) {
                  // Handle error
                  print(error.toString());
                }
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == true) {
        // User canceled
        if (index >= 0 && index < userRequirements.length) {
          setState(() {
            userRequirements[index]['status'] = 'Cancelled';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: color5,
        title: const Text('REQUIREMENT'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUserRequirementsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userRequirements = snapshot.data!;
            return ListView.builder(
              itemCount: userRequirements.length,
              itemBuilder: (context, index) {
                final userRequirement = userRequirements[index];
                String documentId = userRequirement['documentId'];

                return Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, top: 12, bottom: 15),
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
                                      confirmRequirement(documentId, index);
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
                                      cancelRequirement(documentId, index);
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
                                userRequirement['status'] ?? 'N/A',
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
