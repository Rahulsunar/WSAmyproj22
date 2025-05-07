import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRecordScreen extends StatelessWidget {
  const UserRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Record"), backgroundColor: Colors.pink),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('type', isEqualTo: 'child').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['name'] ?? 'No name'),
                  subtitle: Text('Email: ${doc['email']}\nGuardian Email: ${doc['parentEmail']}\nPhone: ${doc['phone']}'),
                  trailing: Switch(
                    value: doc['blocked'] == true,
                    onChanged: (val) {
                      FirebaseFirestore.instance.collection('users').doc(doc.id).update({'blocked': val});
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