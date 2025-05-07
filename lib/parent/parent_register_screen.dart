import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/guardian/guardian_login_screen.dart';
import 'package:women_safety_app/model/user_model.dart';
import 'package:women_safety_app/utils/constants.dart';

class RegisterParentScreen extends StatefulWidget {
  @override
  State<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
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
            email: _formData['gemail'].toString(),
            password: _formData['password'].toString());
        if (userCredential.user != null) {
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db =
          FirebaseFirestore.instance.collection('users').doc(v);

          final User = UserModel(
            name: _formData['name'].toString(),
            id: v,
            phone: _formData['phone'].toString(),
            childEmail: _formData['cemail'].toString(),
            parentEmail: _formData['gemail'].toString(),
            type: 'parent',
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
        child: isLoading
            ? progressIndicator(context)
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  "REGISTER AS PARENT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/guardian.png',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 24),
                CustomTextfield(
                  hintText: 'Enter Name',
                  textInputAction: TextInputAction.next,
                  keyboardtype: TextInputType.name,
                  prefix: Icon(Icons.person),
                  onsave: (name) {
                    _formData['name'] = name ?? "";
                  },
                  validate: (name) {
                    if (name!.isEmpty || name.length < 3) {
                      return 'Enter Correct Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextfield(
                  hintText: 'Enter Phone',
                  textInputAction: TextInputAction.next,
                  keyboardtype: TextInputType.phone,
                  prefix: Icon(Icons.phone),
                  onsave: (phone) {
                    _formData['phone'] = phone ?? "";
                  },
                  validate: (phone) {
                    if (phone!.isEmpty || phone.length < 10) {
                      return 'Enter Correct Phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextfield(
                  hintText: 'Enter Email',
                  textInputAction: TextInputAction.next,
                  keyboardtype: TextInputType.emailAddress,
                  prefix: Icon(Icons.person),
                  onsave: (email) {
                    _formData['gemail'] = email ?? "";
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
                const SizedBox(height: 12),
                CustomTextfield(
                  hintText: 'Enter Child Email',
                  textInputAction: TextInputAction.next,
                  keyboardtype: TextInputType.emailAddress,
                  prefix: Icon(Icons.person),
                  onsave: (cemail) {
                    _formData['cemail'] = cemail ?? "";
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                CustomTextfield(
                  hintText: 'Retype Password',
                  isPassword: isRetypePasswordShown,
                  prefix: Icon(Icons.vpn_key_rounded),
                  onsave: (password) {
                    _formData['rpassword'] = password ?? "";
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
                        isRetypePasswordShown = !isRetypePasswordShown;
                      });
                    },
                    icon: isRetypePasswordShown
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                  ),
                ),
                const SizedBox(height: 20),
                Primarybutton(
                  title: "REGISTER",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _onSubmit();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Secondarybutton(
                  title: 'Login With Your Account',
                  onPressed: () {
                    goTo(context, GuardianLoginScreen());
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}