import 'dart:developer';

import 'package:alora_admin/screen/requirement/components/reuirment_card.dart';
import 'package:alora_admin/style/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequirementScreen extends StatefulWidget {
  const RequirementScreen({super.key});

  @override
  State<RequirementScreen> createState() => _RequirementScreenState();
}

class _RequirementScreenState extends State<RequirementScreen> {
  @override
  void initState() {
    //getRequirement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color5,
        title: const Text('REQUIREMENT'),
        centerTitle: true,
      ),
      backgroundColor: color1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: StreamBuilder(
              stream: getRequirement,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //log(snapshot.data.toString());
                if (snapshot.data == []) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final data = snapshot.data[index];
                    RequirementCard(
                      userRequir: data,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: color3,
                    );
                  },
                  itemCount: snapshot.data.length,
                );
              }),
        ),
      ),
    );
  }

  Stream getRequirement = (() async* {
    final QuerySnapshot<Map<String, dynamic>> usersStream =
        await FirebaseFirestore.instance.collection('users').get();
    List userRequir = usersStream.docs.map((e) => e.data()).toList();
    log(userRequir.toString());
    yield userRequir;
  })();
}
