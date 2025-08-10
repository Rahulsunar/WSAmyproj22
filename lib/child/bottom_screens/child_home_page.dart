import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';
import 'package:women_safety_app/widgets/home_widgets/CustomCarousel.dart';
import 'package:women_safety_app/widgets/home_widgets/custom_appBar.dart';
import 'package:women_safety_app/widgets/home_widgets/emergency.dart';
import 'package:women_safety_app/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:women_safety_app/widgets/live_safe.dart';

class ChildHomePage extends StatefulWidget {
  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  int qIndex = 0;
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;
  ShakeDetector? shakeDetector;

  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus status = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
    );

    if (!mounted) return;
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

  getRandomQuote() {
    if (!mounted) return;
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  getAndSendSms() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();
    String messageBody =
        "https://maps.google.com/?daddr=${_currentPosition?.latitude ?? 0},${_currentPosition?.longitude ?? 0}";

    if (await _isPermissionGranted()) {
      for (var element in contactList) {
        _sendSms(element.number, "I am in trouble $messageBody");
      }
    } else {
      if (!mounted) return;
      Fluttertoast.showToast(
          msg: "Something went wrong. SMS permission not granted.");
    }
  }

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    _getPermission();
    _getCurrentLocation();

    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        getAndSendSms();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shake detected! Sending alert...')),
        );
      },
    );
  }

  @override
  void dispose() {
    shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomAppbar(
                quoteIndex: qIndex,
                onTap: getRandomQuote,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const CustomCarousel(),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Emergency",
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Emergency(),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Explore LiveSafe",
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const LiveSafe(),
                    // ✅ Removed `const` before Safehome to fix error
                    Safehome(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
