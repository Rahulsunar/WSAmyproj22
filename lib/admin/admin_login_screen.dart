import 'package:flutter/material.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool isPasswordShown = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  void login() async {
    final username = _formData['username']?.toString();
    final password = _formData['password']?.toString();

    if (username == 'admin' && password == 'admin123') {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(Duration(seconds: 1)); // simulate loading
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            isLoading
                ? progressIndicator(context)
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ADMIN LOGIN",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/adminlogo.png',
                          height: 100,
                          width: 100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextfield(
                            hintText: 'Enter Username',
                            prefix: Icon(Icons.person),
                            textInputAction: TextInputAction.next,
                            onsave: (value) {
                              _formData['username'] = value ?? "";
                            },
                            validate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a valid username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16), // spacing between fields
                          CustomTextfield(
                            hintText: 'Enter Password',
                            isPassword: isPasswordShown,
                            prefix: Icon(Icons.vpn_key),
                            onsave: (value) {
                              _formData['password'] = value ?? "";
                            },
                            validate: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordShown = !isPasswordShown;
                                });
                              },
                              icon: Icon(
                                isPasswordShown ? Icons.visibility_off : Icons.visibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24), // spacing before login button
                          Primarybutton(
                            title: "LOGIN",
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                login();
                              }
                            },
                          ),
                          const SizedBox(height: 24), // spacing before forgot password section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Forgot Password?",
                                style: TextStyle(fontSize: 18),
                              ),
                              Secondarybutton(
                                title: 'Click Here',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Forgot password functionality not implemented yet.")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
