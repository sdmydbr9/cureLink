import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProcessContinuationPage extends StatelessWidget {
  final Map<String, dynamic> formData;

  ProcessContinuationPage({required this.formData});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Processing Continuation'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPD Number: ${formData['opdNumber']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Date: ${dateFormat.format(formData['date'])}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Temperature: ${formData['temperature']} ${formData['temperatureUnit']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Body Weight: ${formData['bodyWeight']} kg',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Vaccination Status: ${formData['vaccinationStatus']}',
              style: TextStyle(fontSize: 16),
            ),
            if (formData['vaccinationStatus'] == 'Yes')
              Text(
                'Vaccination Date: ${dateFormat.format(formData['vaccinationDate'])}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 8.0),
            Text(
              'Deworming Status: ${formData['dewormingStatus']}',
              style: TextStyle(fontSize: 16),
            ),
            if (formData['dewormingStatus'] == 'Yes')
              Text(
                'Deworming Date: ${dateFormat.format(formData['dewormingDate'])}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 8.0),
            Text(
              'Symptoms: ${formData['symptoms']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Treatments:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                formData['treatments'].length,
                (index) => Text(
                  'Treatment ${index + 1}: ${formData['treatments'][index].toString()}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Advice: ${formData['advice']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
