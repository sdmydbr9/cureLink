import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../calculate/fetch.dart';

class PopupCalculatorScreen extends StatefulWidget {
  final String medicationName;
  final void Function(String, String, String, int, int, List<dynamic>)
      updateResultCard;
  final void Function(String, String) onMedicationInfoChanged;

  PopupCalculatorScreen({
    required this.medicationName,
    required this.updateResultCard,
    required this.onMedicationInfoChanged,
  });

  @override
  _PopupCalculatorScreenState createState() => _PopupCalculatorScreenState();
}

class _PopupCalculatorScreenState extends State<PopupCalculatorScreen> {
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController bodyWeightController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _calculationResult = {};

  int _lowerDoseRate = 0; // Variable to store the lower dose rate
  int _upperDoseRate = 0; // Variable to store the upper dose rate
  List<dynamic> _medications =
      []; // Variable to store the list of medications// Added variable to store the calculation result

  Future<Map<String, dynamic>> calculateMedication(
    String name,
    String species,
    double bodyWeight,
  ) async {
    final encodedSpecies =
        Uri.encodeComponent(species); // Encode the species part of the URL
    final apiUrl =
        'https://www.pethealthwizard.tech:8000/calculate-medication/$name/$encodedSpecies/$bodyWeight';

    print('API URL: $apiUrl');

    final response = await http.get(Uri.parse(apiUrl));
    print('API Response: ${response.body}');

    final data = jsonDecode(response.body);

    // Check if the 'dose_rate' is in range format [lower, upper]
    if (data['dose_rate'] is List && data['dose_rate'].length == 2) {
      // Parse 'dose_rate' values into integers
      int lowerDoseRate = int.parse(data['dose_rate'][0]);
      int upperDoseRate = int.parse(data['dose_rate'][1]);
      data['dose_rate'] = [lowerDoseRate, upperDoseRate];
    } else if (data['dose_rate'] is num) {
      // Handle non-range dose_rate by converting it to a list with the same value for lower and upper dose rate
      int singleDoseRate = data['dose_rate'].toInt();
      data['dose_rate'] = [singleDoseRate, singleDoseRate];
    } else {
      // Handle other cases where dose_rate is not in the expected format
      // You can show an error dialog or handle it as per your application's logic
      throw Exception('Invalid dose_rate format in API response');
    }

    print('Calculated Dose Rate: ${data['dose_rate']}');

    return data;
  }

  void performMedicationCalculation(
    BuildContext context,
    String medicationName,
    String species,
    double bodyWeight,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Performing Medication Calculation...');
      print('Medication Name: $medicationName');
      print('Species: $species');
      print('Body Weight: $bodyWeight');

      Map<String, dynamic> calculationResult =
          await calculateMedication(medicationName, species, bodyWeight);
      print('Calculation Result: $calculationResult');

      if (calculationResult.containsKey('error')) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Text(calculationResult['error']),
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
      } else {
        String formattedResult = _showCalculationResults(calculationResult);

        setState(() {
          _calculationResult =
              calculationResult; // Update the calculation result
        });

        widget.updateResultCard(
          formattedResult,
          medicationName,
          species,
          _lowerDoseRate,
          _upperDoseRate,
          _medications,
        );

        widget.onMedicationInfoChanged(medicationName, species);

        Navigator.of(context).pop();
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while fetching the calculation result.'),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _showCalculationResults(Map<String, dynamic> result) {
    // Extract relevant information from the response
    String medicationName = result['medication'];
    String species = result['species'];
    List<dynamic> doseRate = result['dose_rate'];
    List<dynamic> medications = result['medications'];

    // Create a formatted string for display
    String formattedResult = 'Medication Name: $medicationName\n'
        'Species: $species\n'
        'Dose Rate: ${doseRate[0]} - ${doseRate[1]} mg/kg\n'
        'Body Weight: ${result['body_weight']} kg\n\n';

    print('Formatting result for $medicationName');

    // Add a separate card for each medication details
    for (var medication in medications) {
      print('Formatting medication details: ${medication['name']}');

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
              var volumeRange = volume.split('-');
              var lowerVolume = double.parse(volumeRange[0].trim());
              var upperVolume = double.parse(volumeRange[1].trim());
              formattedResult +=
                  '\n  Volume Range: ${formatVolumeRange(lowerVolume, upperVolume)}';
            } else {
              var singleVolume = double.parse(volume.trim());
              formattedResult += '\n  Volume: ${roundVolume(singleVolume)}';
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

    print('Formatted result: \n$formattedResult');
    return formattedResult;
  }

// Helper function to round the volume to two decimal places
  String roundVolume(double volume) {
    return volume.toStringAsFixed(2);
  }

// Helper function to format the volume range with two decimal places
  String formatVolumeRange(double lower, double upper) {
    return '${roundVolume(lower)} - ${roundVolume(upper)}';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the desired height as 80% of the screen height
    final double desiredHeight = MediaQuery.of(context).size.height * 0.8;

    // Make sure the currentHeight is not less than minHeight or greater than maxHeight
    final double minHeight = 200.0;
    final double maxHeight = 800.0;
    double currentHeight = desiredHeight.clamp(minHeight, maxHeight);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            // Detect vertical drag and update the currentHeight accordingly
            setState(() {
              currentHeight = currentHeight - details.delta.dy;
              if (currentHeight < minHeight) {
                currentHeight = minHeight;
              } else if (currentHeight > maxHeight) {
                currentHeight = maxHeight;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: currentHeight,
            child: CupertinoPopupSurface(
              isSurfacePainted: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ), // Add space between navigation bar and text fields
                    TypeAheadFormField<String>(
                      loadingBuilder: (BuildContext context) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: speciesController,
                        decoration: InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return await fetchSpecies(
                            pattern, widget.medicationName);
                      },
                      itemBuilder: (context, String suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (String suggestion) {
                        speciesController.text = suggestion;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a species';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: bodyWeightController,
                      decoration: InputDecoration(
                        labelText: 'Body Weight (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.grey),
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
                    const SizedBox(height: 16.0),
                    CupertinoButton.filled(
                      child: _isLoading
                          ? const CupertinoActivityIndicator()
                          : const Text('Calculate',
                              style: TextStyle(fontSize: 18)),
                      onPressed: _isLoading
                          ? null
                          : () {
                              String name = widget.medicationName;
                              String species = speciesController.text;
                              double? bodyWeight =
                                  double.tryParse(bodyWeightController.text);

                              if (bodyWeight == null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'Please enter a valid body weight'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                return;
                              }

                              // Perform the medication calculation
                              performMedicationCalculation(
                                context,
                                widget.medicationName,
                                species,
                                bodyWeight,
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
