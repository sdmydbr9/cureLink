import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditScreen extends StatefulWidget {
  final int medicationId;

  EditScreen({required this.medicationId});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  Map<String, dynamic> medicationData = {};

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMedicationData();
  }

  Future<void> fetchMedicationData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.pethealthwizard.tech:9999/medication/${widget.medicationId}'));
      if (response.statusCode == 200) {
        setState(() {
          medicationData = json.decode(response.body);
          _categoryController.text = medicationData['category'];
          _nameController.text = medicationData['name'];
        });
      } else {
        // Handle error
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  Future<void> updateMedication(Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://www.pethealthwizard.tech:9999/medication/${widget.medicationId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Success, medication data updated
        setState(() {
          medicationData = updatedData;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication updated successfully!')),
        );
      } else {
        // Handle error
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  Future<void> deleteMedication() async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://www.pethealthwizard.tech:9999/medication/${widget.medicationId}'),
      );

      if (response.statusCode == 200) {
        // Success, medication deleted
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // Handle error
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement the functionality to update medication data
                Map<String, dynamic> updatedData = {
                  'category': _categoryController.text,
                  'name': _nameController.text,
                  // Add other fields you want to update here
                };
                updateMedication(updatedData);
              },
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement the functionality to delete medication
                deleteMedication();
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Delete Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
