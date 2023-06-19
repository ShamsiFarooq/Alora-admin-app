import 'dart:developer';

import 'package:alora_admin/style/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScreeenHome extends StatefulWidget {
  ScreeenHome({
    super.key,
  });
  @override
  State<ScreeenHome> createState() => _ScreeenHomeState();
}

class _ScreeenHomeState extends State<ScreeenHome> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items;
  bool isLoad = false;

  Stream getRequirement = (() async* {
    final QuerySnapshot<Map<String, dynamic>> usersStream =
        await FirebaseFirestore.instance.collection('users').get();
    List userRequir = usersStream.docs.map((e) => e.data()).toList();
    // log(userRequir.toString());

    yield userRequir;
  })();

  // _incrementCounter() async {
  //   List<Map<String, dynamic>> tempList = [];
  //   var data = await collection.get();
  //   data.docs.forEach((element) {
  //     tempList.add(element.data());
  //   });

  //   setState(() {
  //     items = tempList;
  //     isLoad = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color1,
      appBar: appBar(),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  'Contact Name: ${data['contactname'] ?? ''}',
                  style: TextStyle(
                    fontSize: 18,
                    color: color4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Cleaning Type: ${data['cleanigtype']}'),
              );
            }).toList(),
          );
        },
      ),

      // body: StreamBuilder(
      //   stream: getRequirement,
      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     //log(snapshot.data.toString());
      //     if (snapshot.data == []) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }

      //     return ListView.separated(
      //       itemBuilder: (BuildContext context, int index) {
      //         final data = snapshot.data[index];

      //         return Container(
      //           decoration: BoxDecoration(
      //             color: color2,
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //           height: 300,
      //           child: Padding(
      //             padding: const EdgeInsets.all(10.0),
      //             child: Text(
      //               data.toString(),
      //               style: TextStyle(
      //                 fontSize: 18,
      //                 color: color4,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ),
      //         );
      //       },
      //       separatorBuilder: (BuildContext context, int index) {
      //         return const Divider(
      //           color: color3,
      //         );
      //       },
      //       itemCount: snapshot.data.length,
      //     );
      //   },
      // ),
    );
  }
}
