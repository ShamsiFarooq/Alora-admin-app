import 'package:alora_admin/style/constant.dart';
import 'package:alora_admin/view/privacy/terms_use.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                color: color3,
                borderRadius: BorderRadius.circular(29),
              ),
              child: Center(child: TermsOfUse()),
            ),
          ],
        ),
      ),
    );
  }
}
