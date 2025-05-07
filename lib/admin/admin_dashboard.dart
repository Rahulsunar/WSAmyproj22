import 'package:flutter/material.dart';
import 'guardian_record_screen.dart';
import 'user_record_screen.dart';
import 'ratings_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Admin"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianRecordScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
              child: const Text("Guardian Record"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserRecordScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade100),
              child: const Text("User Record"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade100),
              child: const Text("View Ratings"),
            ),
          ],
        ),
      ),
    );
  }
}
