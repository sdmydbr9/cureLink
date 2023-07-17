import 'package:flutter/material.dart';

class PreprocessScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  PreprocessScreen({required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preprocessing Data'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Date: ${formData['selectedDate']}'),
            Text('Source: ${formData['selectedSource']}'),
            Text('Department: ${formData['selectedDepartment']}'),
            Text('Species: ${formData['selectedSpecies']}'),
            Text('OPD Number: ${formData['opdNumber']}'),
            Text('Sex: ${formData['sex']}'),
            Text(
                'Body Weight: ${formData['bodyWeightKg']} kg ${formData['bodyWeightGm']} gm'),
            Text('Temperature: ${formData['temperature']}'),
            Text('Heart Rate: ${formData['heartRate']}'),
            Text('Pulse Rate: ${formData['pulseRate']}'),
            Text('Vaccination: ${formData['hasVaccination']}'),
            Text('Vaccination Date: ${formData['vaccinationDate']}'),
            Text('Deworming: ${formData['hasDeworming']}'),
            Text('Deworming Date: ${formData['dewormingDate']}'),
            Text('Symptoms: ${formData['symptoms']}'),
            Text('Treatment: ${formData['treatments']}'),
            Text('Advice: ${formData['advice']}'),
            Text('Pregnant: ${formData['isPregnant']}'),
            Text('Pregnancy Duration: ${formData['pregnancyDuration']}'),
          ],
        ),
      ),
    );
  }
}
