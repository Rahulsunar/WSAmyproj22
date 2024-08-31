import 'package:flutter/material.dart';

class Pharmacycard extends StatelessWidget {
  final Function? onMapFunction;
  const Pharmacycard({Key? key, this.onMapFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onMapFunction!('Pharmacies Near Me');
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    'assets/pharmacy.png',
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text('Pharmacy')
        ],
      ),
    );
  }
}
