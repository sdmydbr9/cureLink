import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'info_screen.dart';

class ProcessDosageScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dosageList;
  final List<Map<String, dynamic>> medicationList;
  final String category;
  final String name;

  ProcessDosageScreen({
    required this.dosageList,
    required this.medicationList,
    required this.category,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return DosageMedicationScreen(
      dosageList: dosageList,
      medicationList: medicationList,
      category: category,
      name: name,
    );
  }
}

class DosageMedicationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> dosageList;
  final List<Map<String, dynamic>> medicationList;
  final String category;
  final String name;

  DosageMedicationScreen({
    required this.dosageList,
    required this.medicationList,
    required this.category,
    required this.name,
  });

  @override
  _DosageMedicationScreenState createState() => _DosageMedicationScreenState();
}

class _DosageMedicationScreenState extends State<DosageMedicationScreen> {
  bool _isLoading = false; // State variable to track loading state

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        primaryColor: Color.fromARGB(255, 0, 64, 221),
      ),
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Column(
            children: [
              Text(
                widget.category.isEmpty ? 'None' : widget.category,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Text(
                widget.name.isEmpty ? 'None' : widget.name,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : () => _saveData(context),
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : const Text('Save'),
          ),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.doc_append),
                  label: 'Dosage List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bandage),
                  label: 'Medication List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.info),
                  label: 'Info',
                ),
              ],
            ),
            backgroundColor: CupertinoColors.lightBackgroundGray,
            tabBuilder: (context, index) {
              if (index == 0) {
                return _buildDosageList();
              } else if (index == 1) {
                return _buildMedicationList();
              } else {
                // Navigate to the MedicineInfoScreen
                return MedicineInfo();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDosageList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.dosageList.length,
          itemBuilder: (context, index) {
            final dosage = widget.dosageList[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.paw_solid),
                        const SizedBox(width: 8),
                        Text(
                          'Species: ${dosage['species'] ?? 'None'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.chart_bar_square),
                        const SizedBox(width: 8),
                        Text(
                          'Dosage: ${dosage['dosage'] ?? 'None'} ${dosage['unit'] ?? 'None'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.person_fill),
                        const SizedBox(width: 8),
                        Text(
                          'Body Weight: ${dosage['bodyWeight'] ?? 'None'} ${dosage['weightUnit'] ?? 'None'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.arrow_turn_up_right),
                        const SizedBox(width: 8),
                        Text(
                          'Route of Administration: ${dosage['route'] ?? 'None'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.medicationList.length,
          itemBuilder: (context, index) {
            final medication = widget.medicationList[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons
                                  .line_horizontal_3_decrease_circle_fill),
                              const SizedBox(width: 8),
                              Text(
                                'Medication Row ${index + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.eyedropper_halffull),
                              const SizedBox(width: 8),
                              Text('Type: ${medication['type'] ?? 'None'}'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.textformat),
                              const SizedBox(width: 8),
                              Text('Name: ${medication['name'] ?? 'None'}'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.percent),
                              const SizedBox(width: 8),
                              Text(
                                'Concentration: ${medication['concentration'] ?? 'None'} ${medication['unit'] ?? 'None'}',
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.drop_fill),
                              const SizedBox(width: 8),
                              Text(
                                'Presentation: ${medication['presentation'] ?? 'None'} ${medication['presentationUnit'] ?? 'None'}',
                              ),
                            ],
                          ),
                          if (medication['type'] ==
                              'Reconstitutable injectables')
                            Text(
                                'Reconstitution: ${_buildReconstitutionInfo(medication)}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildImagePreview(medication),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildReconstitutionInfo(Map<String, dynamic> medication) {
    String value = medication['reconstitutionValue'] ?? 'N/A';
    String unit = medication['reconstitutionUnit'] ?? 'N/A';
    return 'Value: $value $unit';
  }

  Widget _buildImagePreview(Map<String, dynamic> medication) {
    if (medication['image'] is Uint8List) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(8), // Set the border radius as desired
        child: Image.memory(
          medication['image'],
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else if (medication['image'] is String) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(8), // Set the border radius as desired
        child: Image.network(
          medication['image'],
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Text('N/A');
    }
  }

  void _saveData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    // Convert image data to base64 for each medication entry
    List<Map<String, dynamic>> updatedMedicationList = [];
    for (var medication in widget.medicationList) {
      String? encodedImage;
      var rawImage = medication['image'];

      if (rawImage != null && rawImage is Uint8List) {
        encodedImage = base64.encode(rawImage);
      }

      Map<String, dynamic> updatedMedication = Map.from(medication);
      updatedMedication['image'] = encodedImage;
      updatedMedicationList.add(updatedMedication);
    }

    // Create your data JSON with the updated medication list
    var data = {
      "category": widget.category,
      "name": widget.name,
      "dosageList": widget.dosageList,
      "medicationList": updatedMedicationList,
    };

    // Print the JSON data before making the API request
    print('JSON Data: ${jsonEncode(data)}');

    // Send the data as JSON in the request to the Flask app
    var url =
        'https://www.pethealthwizard.tech:9999/submit'; // Replace with your API endpoint URL
    var headers = {
      'Content-Type': 'application/json',
    };
    var jsonBody = jsonEncode(data);

    try {
      var response =
          await http.post(Uri.parse(url), headers: headers, body: jsonBody);
      if (response.statusCode == 200) {
        _showSaveSuccessDialog(context);
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMedicineInfoScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => MedicineInfo()),
    );
  }

  void _showSaveSuccessDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Data saved successfully.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// MedicationScreen class, replace this with the actual MedicationScreen implementation
class MedicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Screen'),
      ),
      body: const Center(
        child: Text('Medication Screen'),
      ),
    );
  }
}
