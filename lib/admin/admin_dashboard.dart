import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'guardian_record_screen.dart';
import 'user_record_screen.dart';
import 'ratings_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Implement Baaki xa logout logic ko
              Navigator.pop(context);
            },
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDashboardButton(
                  context,
                  label: 'Gurdian-Record', // kept same as screenshot
                  color: Colors.green.shade100,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianRecordScreen())),
                ),
                _buildDashboardButton(
                  context,
                  label: 'User-Record',
                  color: Colors.yellow.shade100,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserRecordScreen())),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildDashboardButton(
              context,
              label: 'View Ratings',
              color: Colors.purple.shade200,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingsScreen())),
              widthFactor: 0.9,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required String label,
        required Color color,
        required VoidCallback onPressed,
        double widthFactor = 0.4}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
