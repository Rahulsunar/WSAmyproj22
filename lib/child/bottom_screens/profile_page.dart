import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadUrl;
  bool IsSaving = false;

  getData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        nameC.text = value.docs.first['name'];
        id = value.docs.first.id;
        profilePic = value.docs.first['profilePic'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IsSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final XFile? pickImage =
                          await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 50,
                          );
                          if (pickImage != null) {
                            setState(() {
                              profilePic = pickImage.path;
                            });
                          }
                        },
                        child: profilePic == null
                            ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          child: Icon(Icons.add_a_photo,
                              size: 40, color: Colors.pink),
                        )
                            : CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profilePic!
                              .contains('http')
                              ? NetworkImage(profilePic!)
                          as ImageProvider
                              : FileImage(File(profilePic!)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Update Your Profile",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: key,
                  child: Column(
                    children: [
                      CustomTextfield(
                        controller: nameC,
                        hintText: "Enter your name",
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'Please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      Primarybutton(
                        title: "UPDATE",
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            profilePic == null
                                ? Fluttertoast.showToast(
                                msg: 'Please select a profile picture')
                                : update();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          "LOGOUT",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: logout,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = const Uuid().v4();
      final Reference fbStorage =
      FirebaseStorage.instance.ref('profile').child(fileName);

      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask;
      downloadUrl = await fbStorage.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  update() async {
    setState(() => IsSaving = true);
    await uploadImage(profilePic!).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': nameC.text,
        'profilePic': downloadUrl,
      });
      setState(() => IsSaving = false);
      Fluttertoast.showToast(msg: "Profile updated successfully!");
    });
  }
}
