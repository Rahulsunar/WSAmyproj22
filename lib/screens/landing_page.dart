import 'package:flutter/material.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/guardian/guardian_login_screen.dart';
import 'package:women_safety_app/admin/admin_login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.3),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/mainlogo.png',
                      height: 60,
                      width: 60,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    'Login With your account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  _buildLoginButton(
                    context,
                    label: 'Login As User',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoginButton(
                    context,
                    label: 'Login As Gurdian',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GuardianLoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoginButton(
                    context,
                    label: 'Login As Admin',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.pinkAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.pink,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
