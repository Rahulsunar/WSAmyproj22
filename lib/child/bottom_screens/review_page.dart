import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/utils/constants.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  bool isSaving = false;
  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Review Your Place"),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextfield(
                      hintText: 'Enter Location',
                      controller: locationC,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextfield(
                      controller: viewsC,
                      hintText: 'Enter Location',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Primarybutton(
                  title: "SAVE",
                  onPressed: () {
                    saveReview();
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance.collection('reviews').add({
      'location': locationC.text,
      'views': viewsC.text,
    }).then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Review uploaded successfully');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving == true
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Text(
                    "Recent Review by others",
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                  Expanded(
                      child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        // Show the loading indicator only if it's the first load and there is no data yet
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        // Show a message if there are no reviews
                        return Center(child: Text("No reviews available."));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final data = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                title: Text(
                                  data['location'],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                subtitle: Text(data['views']),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
