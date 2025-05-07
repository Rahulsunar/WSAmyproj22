import 'package:flutter/material.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/guardian/guardian_login_screen.dart';
import 'package:women_safety_app/admin/admin_login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 40),
              const Text(
                'Login With your account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                child: const Text('Login As User'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianLoginScreen())),
                child: const Text('Login As Guardian'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                child: const Text('Login As Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}