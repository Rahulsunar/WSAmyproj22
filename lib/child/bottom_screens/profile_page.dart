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
          ? Center(child: CircularProgressIndicator(backgroundColor: Colors.pink))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("UPDATE YOUR PROFILE", style: TextStyle(fontSize: 25)),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      final XFile? pickImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery, imageQuality: 50);
                      if (pickImage != null) {
                        setState(() {
                          profilePic = pickImage.path;
                        });
                      }
                    },
                    child: profilePic == null
                        ? CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 80,
                        child: Center(
                            child: Image.asset('assets/add_pic.png',
                                height: 80, width: 80)))
                        : profilePic!.contains('http')
                        ? CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      radius: 80,
                      backgroundImage: NetworkImage(profilePic!),
                    )
                        : CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 80,
                        backgroundImage: FileImage(File(profilePic!))),
                  ),
                  CustomTextfield(
                    controller: nameC,
                    hintText: nameC.text,
                    validate: (v) {
                      if (v!.isEmpty) {
                        return 'please enter your updated name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25),
                  Primarybutton(
                    title: "UPDATE",
                    onPressed: () async {
                      if (key.currentState!.validate()) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        profilePic == null
                            ? Fluttertoast.showToast(
                            msg: 'please select profile picture')
                            : update();
                      }
                    },
                  ),

                  // 🔹 LOGOUT BUTTON ADDED HERE
                  SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: logout, // Calls the logout function
                    child: Text("LOGOUT", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 LOGOUT FUNCTION
  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = Uuid().v4();
      final Reference fbStorage = FirebaseStorage.instance.ref('profile').child(fileName);

      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask.then((p0) async {
        downloadUrl = await fbStorage.getDownloadURL();
      });
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  update() async {
    setState(() {
      IsSaving = true;
    });
    uploadImage(profilePic!).then((value) {
      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilePic': downloadUrl,
      };
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(data);
      setState(() {
        IsSaving = false;
      });
    });
  }
}
