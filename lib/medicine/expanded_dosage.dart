import 'package:flutter/material.dart';
import 'mediationdetailscreen.dart';

class ExpandedDosageCard extends StatelessWidget {
  final Map<String, dynamic> dosage;
  final Map<String, String> speciesIconMap;

  ExpandedDosageCard({required this.dosage, required this.speciesIconMap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('${dosage['species']} Dosage'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Dosage: ${dosage['dosage']} ${dosage['unit']} / ${dosage['bodyWeight']} ${dosage['weightUnit']}'),
                  SizedBox(height: 8),
                  Text('Route: ${dosage['route']}'),
                  SizedBox(height: 8),
                  Text(
                    'Enter Body Weight:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter body weight',
                    ),
                    onChanged: (value) {
                      // You can handle body weight changes here
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle info button press here
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Info'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/${speciesIconMap[dosage['species']] ?? 'default.png'}',
                    width: 32,
                    height: 32,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dosage['species']} Dosage: ${dosage['dosage']} ${dosage['unit']} / ${dosage['bodyWeight']} ${dosage['weightUnit']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
