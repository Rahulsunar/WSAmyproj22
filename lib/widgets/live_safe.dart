import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:women_safety_app/widgets/home_widgets/live_safe/BusStationCard.dart';
import 'package:women_safety_app/widgets/home_widgets/live_safe/HospitalCard.dart';
import 'package:women_safety_app/widgets/home_widgets/live_safe/PharmacyCard.dart';
import 'package:women_safety_app/widgets/home_widgets/live_safe/PoliceStationCard.dart';
import 'package:women_safety_app/screens/emergency_map_screen.dart';


class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> OpenMap(String location) async {
    String googleurl = 'https://www.google.com/maps/search/$location';
    final Uri _url = Uri.parse(googleurl);
    try {
      await launchUrl(_url);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'something went wrong!! Call emergency number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 90,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: [
              PoliceEmergency(onMapFunction: OpenMap),
              Hospitalcard(onMapFunction: OpenMap),
              Pharmacycard(onMapFunction: OpenMap),
              Busstationcard(onMapFunction: OpenMap),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyMapScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            icon: Icon(Icons.map),
            label: Text(
              "Find Nearest Emergency Help",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }}
