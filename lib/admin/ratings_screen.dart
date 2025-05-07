import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ratings"), backgroundColor: Colors.pink),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                color: Colors.pink.shade100,
                child: ListTile(
                  title: Text('Title: ${doc['location']}'),
                  subtitle: Text('Detail: ${doc['views']}'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
