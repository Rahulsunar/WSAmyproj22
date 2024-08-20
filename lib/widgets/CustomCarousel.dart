import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/quotes.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel_slider package

class CustomCarousel extends StatelessWidget {
  const CustomCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          autoPlay:
              true, // Use autoPlay instead of autoplay if required by your package version
        ),
        items: List.generate(imageSliders.length, (index) {
          return Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      imageSliders[index]), // Access the image here
                  fit: BoxFit.cover, // Fit the image inside the card
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
