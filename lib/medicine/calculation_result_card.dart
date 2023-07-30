import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalculationResultCard extends StatelessWidget {
  final String result;

  CalculationResultCard({required this.result}) {
    print('Creating CalculationResultCard');
  }

  @override
  Widget build(BuildContext context) {
    // Set a fixed height for the card
    final double cardHeight = 200.0;

    return SizedBox(
      height: cardHeight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color for the result box
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey[400]!, // Border color
              width: 1.0, // Border width
            ),
          ),
          child: SingleChildScrollView(
            // Enable scrolling for the result inside the card
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Calculation Result',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    result ?? 'No results yet',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
