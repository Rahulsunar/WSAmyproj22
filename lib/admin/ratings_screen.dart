import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  void _showAddRatingDialog(BuildContext context) {
    final locationController = TextEditingController();
    final viewsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Rating"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: viewsController,
              decoration: const InputDecoration(labelText: 'Review'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (locationController.text.isNotEmpty && viewsController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('reviews').add({
                  'location': locationController.text,
                  'views': viewsController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Fluttertoast.showToast(msg: "Rating added successfully");
                Navigator.pop(context);
              } else {
                Fluttertoast.showToast(msg: "Please fill in all fields");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deleteRating(BuildContext context, String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Rating"),
        content: const Text("Are you sure you want to delete this rating?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('reviews').doc(docId).delete();
      Fluttertoast.showToast(msg: "Rating deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ratings"), backgroundColor: Colors.pink),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .snapshots(), // ✅ works for all ratings
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No ratings found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                color: Colors.pink.shade50,
                child: ListTile(
                  title: Text("Location: ${data['location'] ?? 'Unknown'}"),
                  subtitle: Text("Review: ${data['views'] ?? 'No details'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRating(context, doc.id),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRatingDialog(context),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
