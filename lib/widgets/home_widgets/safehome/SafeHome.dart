import 'package:background_sms/background_sms.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:women_safety_app/screens/emergency_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';

class Safehome extends StatefulWidget {
  @override
  State<Safehome> createState() => _SafehomeState();
}

class _SafehomeState extends State<Safehome> {
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus status = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    );

    if (!mounted) return; // ✅ Prevent UI updates after dispose
    Fluttertoast.showToast(
      msg: status == SmsStatus.sent
          ? "Message sent successfully"
          : "Failed to send message",
    );
  }

  _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: "Please enable location services.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        Fluttertoast.showToast(msg: "Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      Fluttertoast.showToast(
          msg: "Location permissions are permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatlon();
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  _getAddressFromLatlon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (!mounted) return;
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        "${place.locality},${place.postalCode},${place.street},";
      });
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getCurrentLocation();
  }

  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SEND YOUR CURRENT LOCATION IMMEDIATELY TO YOUR EMERGENCY CONTACTS",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                if (_currentPosition != null) Text(_currentAddress ?? ''),
                Primarybutton(
                  title: "GET LOCATION",
                  onPressed: _getCurrentLocation,
                ),
                const SizedBox(height: 10),
                Primarybutton(
                  title: "SEND ALERT",
                  onPressed: () async {
                    List<TContact> contactList =
                    await DatabaseHelper().getContactList();

                    String lat =
                        _currentPosition?.latitude.toString() ?? "0.0";
                    String lng =
                        _currentPosition?.longitude.toString() ?? "0.0";

                    String messageBody =
                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

                    if (await _isPermissionGranted()) {
                      for (var element in contactList) {
                        _sendSms(
                          element.number,
                          "I am in trouble. My location: $messageBody",
                        );
                      }
                    } else {
                      if (!mounted) return;
                      Fluttertoast.showToast(
                        msg: "SMS permission not granted.",
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Primarybutton(
                  title: "SHOW NEAREST HELP ON MAP",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmergencyMapScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: const [
                    ListTile(
                      title: Text("Send Location"),
                      subtitle: Text("Share Location"),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/route.jpg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
