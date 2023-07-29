import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'fetch.dart';
import 'calculate.dart';
import 'anaesthesia.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController bodyWeightController = TextEditingController();

  bool _isLoading = false; // New variable to track loading state

  Future<void> calculateMedication() async {
    setState(() {
      _isLoading = true;
    });

    String name = nameController.text;
    String species = speciesController.text;
    double? bodyWeight = double.tryParse(bodyWeightController.text);

    if (bodyWeight == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Please enter a valid body weight'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isLoading = false;
      });

      return;
    }

    Map<String, dynamic> result =
        await MedicationCalculator.calculateMedication(
            name, species, bodyWeight!);

    // Create a formatted string for display
    var formattedResult = 'Medication: ${result['medication']}\n'
        'Species: ${result['species']}\n'
        'Dose Rate: ${result['dose_rate']} mg/kg\n'
        'Body Weight: ${result['body_weight']} kg\n'
        'Medications:\n';

// Function to round the volume or volume range to the nearest tenth
    String roundVolume(String volume) {
      try {
        var volumes = volume.split('-'); // Split the volume range by hyphen '-'
        var parsedVolumes = volumes.map((v) => double.parse(v)).toList();
        var roundedVolumes =
            parsedVolumes.map((v) => (v * 10).floorToDouble() / 10).toList();
        return roundedVolumes
            .join(' - '); // Join the rounded volumes with a hyphen
      } catch (e) {
        return volume;
      }
    }

// Loop through each medication in the 'medications' list
    for (var medication in result['medications']) {
      // Add medication name
      formattedResult += '- Medication: ${medication['name']}';

      // Check the medication type and add relevant information
      if (medication.containsKey('tablets_range')) {
        // For tablet-type medications
        formattedResult += '\n  Type: Tab';
        formattedResult +=
            '\n  Tablets Range: ${medication['tablets_range']} tablets';
      } else if (medication.containsKey('type')) {
        var lowerCaseType = medication['type'].toLowerCase();
        // For other medication types
        formattedResult += '\n  Type: $lowerCaseType';

        if (lowerCaseType == 'inj' || lowerCaseType == 'vial') {
          // For 'inj' or 'vial'
          if (medication.containsKey('volume')) {
            var volume = medication['volume'];
            var isRange = volume.contains('-');
            if (isRange) {
              formattedResult += '\n  Volume Range: $volume';
            } else {
              formattedResult += '\n  Volume: ${roundVolume(volume)}';
            }
          } else {
            formattedResult += '\n  Volume: Not specified';
          }
        } else if (lowerCaseType == 'reconstitutable injectables' ||
            lowerCaseType == 'reconstitutable solution') {
          // For 'Reconstitutable injectables' or 'Reconstitutable solution'
          formattedResult +=
              '\n  Concentration: ${medication['concentration']}';

          if (medication.containsKey('injection_volume_range')) {
            formattedResult +=
                '\n  Injection Volume Range: ${medication['injection_volume_range']}';
          }
        }
      }

      formattedResult += '\n\n'; // Add a blank line after each medication
    }

    setState(() {
      _isLoading = false;
    });

    // Show the results in a dialog box
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Calculation Results'),
          content: Text(formattedResult),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height:
                    40.0), // Add space between navigation bar and text fields
            TypeAheadFormField<Medication>(
              loadingBuilder: (BuildContext context) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await fetchMedications(pattern);
              },
              itemBuilder: (context, Medication medication) {
                return ListTile(
                  title: Text(medication.name),
                );
              },
              onSuggestionSelected: (Medication medication) {
                nameController.text = medication.name;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a medication name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TypeAheadFormField<String>(
              loadingBuilder: (BuildContext context) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: speciesController,
                decoration: InputDecoration(
                  labelText: 'Species',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await fetchSpecies(pattern, nameController.text);
              },
              itemBuilder: (context, String species) {
                return ListTile(
                  title: Text(species),
                );
              },
              onSuggestionSelected: (String species) {
                speciesController.text = species;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a species';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: bodyWeightController,
              decoration: InputDecoration(
                labelText: 'Body Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a body weight';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            CupertinoButton.filled(
              child: _isLoading
                  ? CupertinoActivityIndicator()
                  : Text('Calculate', style: TextStyle(fontSize: 18)),
              onPressed: _isLoading ? null : calculateMedication,
            ),
          ],
        ),
      ),
    );
  }
}
