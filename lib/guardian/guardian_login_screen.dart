import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/child/bottom_page.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/child/register_child.dart';
import 'package:women_safety_app/db/share_pref.dart';
import 'package:women_safety_app/child/bottom_screens/child_home_page.dart';
import 'package:women_safety_app/parent/parent_home_screen.dart';
import 'package:women_safety_app/parent/parent_register_screen.dart';
import 'package:women_safety_app/utils/constants.dart';

class GuardianLoginScreen extends StatefulWidget {
  @override
  State<GuardianLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<GuardianLoginScreen> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _formData['email'].toString(),
          password: _formData['password'].toString());
      if (userCredential.user != null) {
        setState(() {
          isLoading = false;
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((value) {
          if (value['type'] == 'parent') {
            print(value['type']);
            MySharedPrefference.saveUserType('parent');
            goTo(context, ParentHomeScreen());
          } else {
            MySharedPrefference.saveUserType('child');

            goTo(context, BottomPage());
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      if (e.code == 'user-not-found') {
        dialougeBox(context, 'No user found for that email.');
        print('No user found for that email.');
      } else if (e.code == "invalid-credential") {
        dialougeBox(context, 'Invalid Credential.');
      } else if (e.code == 'wrong-password') {
        dialougeBox(context, 'Wrong password provided for that user.');
        print('Wrong password provided for that user.');
      }
    }
    print(_formData['email']);
    print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? progressIndicator(context)
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "GUARDIAN LOGIN",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/guardian.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 24),
                  CustomTextfield(
                    hintText: 'Enter Email',
                    textInputAction: TextInputAction.next,
                    keyboardtype: TextInputType.emailAddress,
                    prefix: Icon(Icons.person),
                    onsave: (email) {
                      _formData['email'] = email ?? "";
                    },
                    validate: (email) {
                      if (email!.isEmpty ||
                          email.length < 3 ||
                          !email.contains("@")) {
                        return 'Enter Correct Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    hintText: 'Enter Password',
                    isPassword: isPasswordShown,
                    prefix: Icon(Icons.vpn_key_rounded),
                    onsave: (password) {
                      _formData['password'] = password ?? "";
                    },
                    validate: (password) {
                      if (password!.isEmpty || password.length < 7) {
                        return 'Enter Correct Password';
                      }
                      return null;
                    },
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordShown = !isPasswordShown;
                        });
                      },
                      icon: isPasswordShown
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Primarybutton(
                    title: "LOGIN",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _onSubmit();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 16),
                      ),
                      Secondarybutton(
                        title: 'Click Here',
                        onPressed: () {
                          // Forgot password logic goes here
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Secondarybutton(
                    title: 'Register As Guardian',
                    onPressed: () {
                      goTo(context, RegisterParentScreen());
                    },
                  ),
                  const SizedBox(height: 8),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
