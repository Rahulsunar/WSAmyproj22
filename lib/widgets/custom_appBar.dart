import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/quotes.dart';

class CustomAppbar extends StatelessWidget {
  final Function? onTap;
  final int quoteIndex;

  // Constructor with required named parameters
  CustomAppbar({
    required this.quoteIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(); // Safe call for null check
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          sweetSayings[quoteIndex],
          style: TextStyle(
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
