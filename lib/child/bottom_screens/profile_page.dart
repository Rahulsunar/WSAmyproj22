import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Center(
          child: TextButton(
              onPressed: () async {
                try {
                  FirebaseAuth.instance.signOut();
                  goTo(context, LoginScreen());
                } on FirebaseException catch (e) {
                  dialougeBox(context, e.toString());
                }
              },
              child: Text("SIGN OUT")),
        ),
      ),
    );
  }
}
