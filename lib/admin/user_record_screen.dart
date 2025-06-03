import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRecordScreen extends StatelessWidget {
  const UserRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Record"), backgroundColor: Colors.pink),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'child')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? 'No name'),
                  subtitle: Text(
                    'Email: ${data.containsKey('email') ? data['email'] : 'N/A'}\n'
                        'Guardian Email: ${data.containsKey('parentEmail') ? data['parentEmail'] : 'N/A'}\n'
                        'Phone: ${data.containsKey('phone') ? data['phone'] : 'N/A'}',
                  ),
                  trailing: Switch(
                    value: false,
                    onChanged: (val) async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: Text("Are you sure you want to delete this user?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final deletedData = data;
                        await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("User deleted"),
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(doc.id)
                                    .set(deletedData);
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
