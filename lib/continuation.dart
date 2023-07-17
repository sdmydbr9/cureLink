import 'package:cure_link/process_continuation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cure_link/continuation.dart';
import 'treatment.dart';

class ContinuationPage extends StatefulWidget {
  final String opdNumber;

  ContinuationPage({required this.opdNumber});

  @override
  _ContinuationPageState createState() => _ContinuationPageState();
}

class _ContinuationPageState extends State<ContinuationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _temperatureUnit;
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _kgController = TextEditingController();
  TextEditingController _gramController = TextEditingController();
  String _bodyWeight = '';
  String? _vaccinationStatus;
  DateTime? _vaccinationDate;
  String? _dewormingStatus;
  DateTime? _dewormingDate;
  DateTime? _selectedDate;
  List<Treatment> treatments = [];
  TextEditingController _treatmentController = TextEditingController();
  TextEditingController _symptomsController =
      TextEditingController(); // New controller for symptoms field
  TextEditingController _adviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _temperatureUnit = null;
    _vaccinationStatus = null;
    _vaccinationDate = null;
    _dewormingStatus = null;
    _dewormingDate = null;
    _selectedDate = null;

    // Set initial value for the treatment text field
    _treatmentController.text = getTreatmentText();
    _adviceController = TextEditingController();
    _symptomsController =
        TextEditingController(); // Initialize the symptoms controller
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _kgController.dispose();
    _gramController.dispose();
    _treatmentController.dispose();
    _symptomsController.dispose(); // Dispose of the symptoms controller
    super.dispose();
  }

  void _showTreatmentDialog(BuildContext context) async {
    List<Treatment>? selectedTreatments = await showDialog<List<Treatment>>(
      context: context,
      builder: (BuildContext context) {
        return TreatmentDialog(
          onTreatmentSelected: (selectedTreatments) {
            setState(() {
              treatments = selectedTreatments;
              _treatmentController.text = getTreatmentText();
            });
          },
          previousTreatments: treatments,
        );
      },
    );

    if (selectedTreatments != null) {
      setState(() {
        treatments = selectedTreatments;
        _treatmentController.text = getTreatmentText();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a map to hold the submitted data
      Map<String, dynamic> formData = {
        'date': _selectedDate,
        'opdNumber': widget.opdNumber,
        'temperature': _temperatureController.text,
        'temperatureUnit': _temperatureUnit,
        'bodyWeight': _bodyWeight,
        'vaccinationStatus': _vaccinationStatus,
        'vaccinationDate': _vaccinationDate,
        'dewormingStatus': _dewormingStatus,
        'dewormingDate': _dewormingDate,
        'symptoms': _symptomsController.text,
        'treatments': treatments,
        'advice': _adviceController.text,
      };

      // Navigate to the process continuation page and pass the form data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessContinuationPage(formData: formData),
        ),
      );
    }
  }

  void handleTreatmentSelected(List<Treatment> selectedTreatments) {
    setState(() {
      treatments = selectedTreatments;
      _treatmentController.text = formatTreatments(treatments);
    });
  }

  String getTreatmentText() {
    if (treatments.isEmpty) {
      return '';
    } else {
      String result = '';
      for (int i = 0; i < treatments.length; i++) {
        result += 'Treatment ${i + 1}: ${treatments[i].toString()}\n';
      }
      return result.trim();
    }
  }

  String formatTreatments(List<Treatment> treatments) {
    return treatments.map((treatment) => treatment.toString()).join('\n');
  }

  List<Treatment> parseTreatments(String treatmentsString) {
    List<Treatment> treatments = [];
    List<String> treatmentEntries = treatmentsString.split('\n');
    for (String entry in treatmentEntries) {
      List<String> parts = entry.split(' - ');
      if (parts.length == 2) {
        Treatment treatment = Treatment();
        treatment.setType(parts[0].trim());
        treatment.setName(parts[1].trim());
        treatments.add(treatment);
      }
    }
    return treatments;
  }

  void updateBodyWeight() {
    String kg = _kgController.text;
    String gram = _gramController.text;

    double kgValue = double.tryParse(kg) ?? 0.0;
    double gramValue = double.tryParse(gram) ?? 0.0;

    double totalWeight = kgValue + (gramValue / 1000);
    String formattedWeight = totalWeight.toStringAsFixed(1);

    setState(() {
      _bodyWeight = formattedWeight;
    });
  }

  void _showVaccinationDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _vaccinationDate = selectedDate;
      });
    }
  }

  void _showDewormingDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _dewormingDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0, left: 16.0),
            child: Text(
              'OPD Number: ${widget.opdNumber}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.0, right: 16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 5.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('d MMMM yyyy').format(_selectedDate!)
                        : 'select Date',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _temperatureController,
                      decoration: InputDecoration(
                        labelText: 'Temperature',
                        suffixIcon: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _temperatureUnit,
                            hint: Text('Unit'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _temperatureUnit = newValue!;
                              });
                            },
                            items: ['Celsius', 'Fahrenheit']
                                .map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a temperature.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kgController,
                            decoration: InputDecoration(
                              labelText: 'kg',
                              hintText: 'Kilograms',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => updateBodyWeight(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a weight in kg.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _gramController,
                            decoration: InputDecoration(
                              labelText: 'gram',
                              hintText: 'Grams',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => updateBodyWeight(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a weight in gram.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'Body Weight: $_bodyWeight kg',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Vaccination Status'),
                      value: _vaccinationStatus,
                      onChanged: (value) {
                        setState(() {
                          _vaccinationStatus = value;
                          if (value != 'Yes') {
                            _vaccinationDate = null;
                          }
                        });
                      },
                      items: ['None', 'Yes', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a vaccination status.';
                        }
                        return null;
                      },
                    ),
                    if (_vaccinationStatus == 'Yes')
                      ListTile(
                        title: Text('Vaccination Date'),
                        subtitle: Text(
                          _vaccinationDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(_vaccinationDate!)
                              : 'Not selected',
                        ),
                        onTap: _showVaccinationDatePicker,
                      ),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Deworming Status'),
                      value: _dewormingStatus,
                      onChanged: (value) {
                        setState(() {
                          _dewormingStatus = value;
                          if (value != 'Yes') {
                            _dewormingDate = null;
                          }
                        });
                      },
                      items: ['None', 'Yes', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a deworming status.';
                        }
                        return null;
                      },
                    ),
                    if (_dewormingStatus == 'Yes')
                      ListTile(
                        title: Text('Deworming Date'),
                        subtitle: Text(
                          _dewormingDate != null
                              ? DateFormat('yyyy-MM-dd').format(_dewormingDate!)
                              : 'Not selected',
                        ),
                        onTap: _showDewormingDatePicker,
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Symptoms'),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return TreatmentDialog(
                              onTreatmentSelected: handleTreatmentSelected,
                              previousTreatments: treatments,
                            );
                          },
                        );
                      },
                      child: TextFormField(
                        enabled: false,
                        controller: _treatmentController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Treatment',
                        ),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Advice'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
