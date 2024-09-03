import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/model/user_model.dart';
import 'package:women_safety_app/utils/constants.dart';

class RegisterChildScreen extends StatefulWidget {
  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  bool isPasswordShown = true;
  bool isRetypePasswordShown = true;

  final _formKey = GlobalKey<FormState>();

  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();
    if (_formData['password'] != _formData['rpassword']) {
      dialougeBox(context, 'Password And Retype Password Should be Equal!!');
    } else {
      progressIndicator(context);

      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _formData['cemail'].toString(),
                password: _formData['password'].toString());
        if (userCredential.user != null) {
          setState(() {
            isLoading = true;
          });
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db =
              FirebaseFirestore.instance.collection('users').doc(v);

          final User = UserModel(
            name: _formData['name'].toString(),
            id: v,
            phone: _formData['phone'].toString(),
            childEmail: _formData['cemail'].toString(),
            parentEmail: _formData['gemail'].toString(),
          );
          final jsonData = User.toJson();

          await db.set(jsonData).whenComplete(() {
            goTo(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          dialougeBox(context, 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          dialougeBox(context, 'The account already exists for that email.');
        }
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
        dialougeBox(context, e.toString());
      }
    }
    print(_formData['email']);
    print(_formData['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Stack(
            children: [
              isLoading
                  ? progressIndicator(context)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "REGISTER AS CHILD",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Image.asset(
                                  'assets/logo.png',
                                  height: 100,
                                  width: 100,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomTextfield(
                                    hintText: 'Enter Name',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.name,
                                    prefix: Icon(Icons.person),
                                    onsave: (name) {
                                      _formData['name'] = name ?? "";
                                    },
                                    validate: (email) {
                                      if (email!.isEmpty || email.length < 3) {
                                        return 'Enter Correct Name';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomTextfield(
                                    hintText: 'Enter Phone',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.phone,
                                    prefix: Icon(Icons.phone),
                                    onsave: (phone) {
                                      _formData['phone'] = phone ?? "";
                                    },
                                    validate: (email) {
                                      if (email!.isEmpty || email.length < 10) {
                                        return 'Enter Correct phone';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomTextfield(
                                    hintText: 'Enter Email',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.person),
                                    onsave: (email) {
                                      _formData['cemail'] = email ?? "";
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
                                  CustomTextfield(
                                    hintText: 'Enter Guardian Email',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.person),
                                    onsave: (gemail) {
                                      _formData['gemail'] = gemail ?? "";
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
                                  CustomTextfield(
                                    hintText: 'Enter Password',
                                    isPassword: isPasswordShown,
                                    prefix: Icon(Icons.vpn_key_rounded),
                                    onsave: (password) {
                                      _formData['password'] = password ?? "";
                                    },
                                    validate: (password) {
                                      if (password!.isEmpty ||
                                          password.length < 7) {
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
                                            : Icon(Icons.visibility)),
                                  ),
                                  CustomTextfield(
                                    hintText: 'Retype Password',
                                    isPassword: isRetypePasswordShown,
                                    prefix: Icon(Icons.vpn_key_rounded),
                                    onsave: (password) {
                                      _formData['rpassword'] = password ?? "";
                                    },
                                    validate: (password) {
                                      if (password!.isEmpty ||
                                          password.length < 7) {
                                        return 'Enter Correct Password';
                                      }
                                      return null;
                                    },
                                    suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isRetypePasswordShown =
                                                !isRetypePasswordShown;
                                          });
                                        },
                                        icon: isRetypePasswordShown
                                            ? Icon(Icons.visibility_off)
                                            : Icon(Icons.visibility)),
                                  ),
                                  Primarybutton(
                                    title: "REGISTER",
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {}
                                      _onSubmit();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Secondarybutton(
                              title: 'Login With Your Account',
                              onPressed: () {
                                goTo(context, LoginScreen());
                              }),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
