import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/chat_module/chat_screen.dart';
import 'package:women_safety_app/screens/landing_page.dart';
import 'package:women_safety_app/utils/constants.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  void signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      goTo(context, LandingPage());
    } catch (e) {
      dialougeBox(context, e.toString());
    }
  }

  Widget buildChildCard(BuildContext context, DocumentSnapshot d) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListTile(
        onTap: () {
          goTo(
              context,
              ChatScreen(
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                friendId: d.id,
                friendName: d['name'],
              ));
        },
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade200,
          child: Text(
            d['name'].toString()[0].toUpperCase(),
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        title: Text(
          d['name'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.chat, color: Colors.pink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pink, Colors.pinkAccent]),
              ),
              accountName: Text("Parent"),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 35, color: Colors.pink),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("SIGN OUT"),
              onTap: () => signOut(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.pink, Colors.pinkAccent]),
          ),
        ),
        title: Text("Select User"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'child')
            .where('parentEmail',
            isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: progressIndicator(context));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No connected Users found.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return buildChildCard(context, doc);
            },
          );
        },
      ),
    );
  }
}
