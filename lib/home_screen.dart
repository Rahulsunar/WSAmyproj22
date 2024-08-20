import 'dart:math';
import 'package:flutter/material.dart';
import 'package:women_safety_app/widgets/CustomCarousel.dart';
import 'package:women_safety_app/widgets/custom_appBar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;

  getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(6); // Change the quote
    });
  }

  @override
  void initState() {
    getRandomQuote();
    super.initState();
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
              CustomCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}
