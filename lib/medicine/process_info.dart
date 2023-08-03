import 'package:cure_link/medicine/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'info_screen.dart';

class ProcessMedInfo extends StatefulWidget {
  final String compoundName;
  final String selectedSpecies;
  final String mechanismOfAction;
  final String contraindication;
  final String indication;
  final String commonSideEffects;
  final String moreInfo;

  ProcessMedInfo({
    required this.compoundName,
    required this.selectedSpecies,
    required this.mechanismOfAction,
    required this.contraindication,
    required this.indication,
    required this.commonSideEffects,
    required this.moreInfo,
  });

  @override
  _ProcessMedInfoState createState() => _ProcessMedInfoState();
}

class _ProcessMedInfoState extends State<ProcessMedInfo> {
  bool _savingInProgress = false;

  // Function to store the processed information in the database
  Future<void> storeMedicationDetailsInDatabase() async {
    // Build the JSON object with the processed information
    final medicationDetails = {
      'compoundName': widget.compoundName,
      'selectedSpecies': widget.selectedSpecies,
      'mechanismOfAction': widget.mechanismOfAction,
      'contraindication': widget.contraindication,
      'indication': widget.indication,
      'commonSideEffects': widget.commonSideEffects,
      'moreInfo': widget.moreInfo,
    };

    // Convert the medicationDetails map to a JSON string
    final jsonString = jsonEncode(medicationDetails);

    // Send a POST request to the Flask API
    final response = await http.post(
      Uri.parse('https://pethealthwizard.tech:8082/insert_medication_info'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print('Data successfully inserted into the info column.');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }

  void _saveData() async {
    setState(() {
      _savingInProgress = true;
    });

    // Call the function to store the information in the database
    await storeMedicationDetailsInDatabase();

    setState(() {
      _savingInProgress = false;
    });

    // Show success dialog
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Data successfully saved to the database.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) =>
                          ViewScreen(), // Replace with your previous screen widget
                    ));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI using CupertinoPageScaffold
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Processed Info'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildInfoItem('Compound Name', widget.compoundName),
              _buildInfoItem('Recommended For', widget.selectedSpecies),
              _buildInfoItem('Mechanism of Action', widget.mechanismOfAction),
              _buildInfoItem('Contraindication', widget.contraindication),
              _buildInfoItem('Indication', widget.indication),
              _buildInfoItem('Common Side Effects', widget.commonSideEffects),
              _buildInfoItem('More Info', widget.moreInfo),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: _savingInProgress ? null : _saveData,
                child: _savingInProgress
                    ? const CupertinoActivityIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CupertinoTheme.of(context).textTheme.textStyle,
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: CupertinoTheme.of(context)
              .textTheme
              .textStyle
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
      ],
    );
  }
}
