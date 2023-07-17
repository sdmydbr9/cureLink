import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cure_link/pregnancy.dart';
import 'package:cure_link/preprocess.dart';
import 'treatment.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'continuation.dart';
import 'lab_report.dart';
import 'floating_action_button.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  late DateTime? selectedDate;
  late String selectedSource;
  late String selectedDepartment;
  late String selectedSpecies;
  late String opdNumberPrefix;
  late String opdNumber;
  late String sex;
  late String ageYears;
  late String ageMonths;
  late String ageDays;
  double? bodyWeightKg;
  int? bodyWeightGm;
  late String temperature;
  late String unit;
  late String heartRate;
  late String pulseRate;
  late bool hasVaccination;
  late DateTime? vaccinationDate;
  late bool hasDeworming;
  late DateTime? dewormingDate;
  late String symptoms;
  late List<Treatment> treatments;
  late String advice;
  late bool isPregnant;
  late String pregnancyDuration = '';
  late int pregnancyDays;
  late int pregnancyMonths;
  late int pregnancyYears;
  late TextEditingController opdNumberController;
  bool showHeartRatePicker = false;
  bool showPulseRatePicker = false;
  TextEditingController _treatmentController = TextEditingController();
  TextEditingController pregnancyController = TextEditingController();

  List<String> units = ['None', 'Celsius', 'Fahrenheit'];
  late String selectedUnit;
  late TextEditingController treatmentController;

  @override
  void initState() {
    super.initState();
    selectedDate = null;
    selectedSource = '';
    selectedDepartment = '';
    selectedSpecies = '';
    opdNumberPrefix = '';
    opdNumber = '';
    sex = '';
    ageYears = '';
    ageMonths = '';
    ageDays = '';
    bodyWeightKg = null;
    bodyWeightGm = null;
    temperature = '';
    unit = '';
    selectedUnit = 'None';
    heartRate = '';
    pulseRate = '';
    hasVaccination = false;
    vaccinationDate = null;
    hasDeworming = false;
    dewormingDate = null;
    symptoms = '';
    treatments = [];
    advice = '';
    isPregnant = false;
    pregnancyDuration = '';
    pregnancyDays = 0;
    pregnancyMonths = 0;
    pregnancyYears = 0;
    opdNumberController = TextEditingController();
    treatmentController = TextEditingController(text: getTreatmentText());
    treatments = parseTreatments(treatmentController.text);
  }

  void updatePregnancyDuration(int days, int months, int years) {
    setState(() {
      pregnancyDays = days;
      pregnancyMonths = months;
      pregnancyYears = years;
      pregnancyDuration = ' $years year $days days $months months';
    });
  }

  @override
  void dispose() {
    opdNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Set the initial date
      firstDate: DateTime(2000), // Set the range of selectable dates
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Update the selected date
      });
    }
  }

  String getFormattedBodyWeight() {
    if (bodyWeightKg == null && bodyWeightGm == null) {
      return 'Body Weight: ';
    } else {
      double totalWeight = (bodyWeightKg ?? 0) + (bodyWeightGm ?? 0) / 1000;
      return 'Body Weight: ${totalWeight.toStringAsFixed(2)} kg';
    }
  }

  String getFormattedAge() {
    String formattedAge = '';

    if (ageYears.isNotEmpty) {
      formattedAge += '$ageYears.';
    }

    if (ageMonths.isNotEmpty) {
      formattedAge += '$ageMonths ';
    }

    formattedAge += 'year';

    if (ageYears != '1') {
      formattedAge += 's';
    }

    return formattedAge;
  }

  void _navigateToContinuation() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContinuationPage(
                opdNumber: '$opdNumber',
              )),
    );
  }

  void _navigateToLabReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LabReportPage(opdNumber: opdNumber, species: selectedSpecies)),
    );
  }

  void handleTreatmentSelected(List<Treatment> selectedTreatments) {
    setState(() {
      treatments = selectedTreatments;
      treatmentController.text = getTreatmentText();
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
    String result = '';
    for (Treatment treatment in treatments) {
      result += '${treatment.type ?? ''} - ${treatment.name ?? ''}\n';
    }
    return result.trim();
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

  void _showHeartRatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (selectedIndex) {
              setState(() {
                if (selectedIndex == 0) {
                  heartRate = 'None';
                } else {
                  heartRate = (selectedIndex + 29).toString();
                }
                showHeartRatePicker = false;
              });
            },
            children: [
              Text('None'),
              ...List<Widget>.generate(121, (index) {
                return Text('${index + 30} beats per minute');
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPulseRatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (selectedIndex) {
              setState(() {
                if (selectedIndex == 0) {
                  pulseRate = 'None';
                } else {
                  pulseRate = (selectedIndex + 29).toString();
                }
                showPulseRatePicker = false;
              });
            },
            children: [
              Text('None'),
              ...List<Widget>.generate(121, (index) {
                return Text('${index + 30} per minute');
              }),
            ],
          ),
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      // Reset all form fields and variables to their initial values
      selectedDate = null;
      selectedSource = '';
      selectedDepartment = '';
      selectedSpecies = '';
      opdNumberPrefix = '';
      opdNumber = '';
      sex = '';
      ageYears = '';
      ageMonths = '';
      ageDays = '';
      bodyWeightKg = null;
      bodyWeightGm = null;
      temperature = '';
      unit = '';
      selectedUnit = 'None';
      heartRate = '';
      pulseRate = '';
      hasVaccination = false;
      vaccinationDate = null;
      hasDeworming = false;
      dewormingDate = null;
      symptoms = '';
      treatments = [];
      advice = '';
      isPregnant = false;
      pregnancyDays = 0;
      pregnancyMonths = 0;
      pregnancyYears = 0;
      opdNumberController.text = '';
      treatmentController.text = getTreatmentText();
      treatments = parseTreatments(treatmentController.text);
    });
  }

  void _submitForm() {
    // Save the form data
    Map<String, dynamic> formData = {
      'selectedDate': selectedDate,
      'selectedSource': selectedSource,
      'selectedDepartment': selectedDepartment,
      'selectedSpecies': selectedSpecies,
      'opdNumber': opdNumber,
      'sex': sex,
      'bodyWeightKg': bodyWeightKg,
      'bodyWeightGm': bodyWeightGm,
      'temperature': temperature,
      'heartRate': heartRate,
      'pulseRate': pulseRate,
      'hasVaccination': hasVaccination,
      'vaccinationDate': vaccinationDate,
      'hasDeworming': hasDeworming,
      'dewormingDate': dewormingDate,
      'symptoms': symptoms,
      'treatments': treatments,
      'advice': advice,
      'isPregnant': isPregnant,
      'pregnancyDuration': pregnancyDays + pregnancyMonths + pregnancyYears,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreprocessScreen(formData: formData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    treatmentController = TextEditingController(text: getTreatmentText());
    bool showUnitDropdown = false;
    bool showAgePicker = false;
    bool showHeartRatePicker = false;
    bool showPulseRatePicker = false;
    bool showPregnancyOption =
        selectedDepartment == 'Gynecology' && sex == 'Female';
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerWidth = screenWidth * 0.9;
    double containerHeight = screenHeight * 0.7;
    double temperatureWidth = screenWidth * 0.1;
    double unitWidth = screenWidth * 0.2;

    final dateFormat = DateFormat('d MMMM yyyy');
    final formattedDate =
        selectedDate != null ? dateFormat.format(selectedDate!) : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Portal'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: GlassmorphicContainer(
                width: containerWidth,
                height: containerHeight,
                borderRadius: 20,
                blur: 10,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.2),
                    Color(0xFFFFFFFF).withOpacity(0.2),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.5),
                    Color((0xFFFFFFFF)).withOpacity(0.5),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Text(
                            formattedDate.isNotEmpty
                                ? 'Date: $formattedDate'
                                : 'Select Date',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value:
                            selectedSource.isNotEmpty ? selectedSource : null,
                        onChanged: (value) {
                          setState(() {
                            selectedSource = value!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'TVCC',
                            child: Text('TVCC'),
                          ),
                          DropdownMenuItem(
                            value: 'State Veterinary Hospital',
                            child: Text('State Veterinary Hospital'),
                          ),
                          DropdownMenuItem(
                            value: 'Dispensary',
                            child: Text('Dispensary'),
                          ),
                          DropdownMenuItem(
                            value: 'Private',
                            child: Text('Private'),
                          ),
                          DropdownMenuItem(
                            value: 'Others',
                            child: Text('Others'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Source',
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedDepartment.isNotEmpty
                            ? selectedDepartment
                            : null,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Medicine',
                            child: Text('Medicine'),
                          ),
                          DropdownMenuItem(
                            value: 'Surgery',
                            child: Text('Surgery'),
                          ),
                          DropdownMenuItem(
                            value: 'Gynecology',
                            child: Text('Gynecology'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Department',
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value:
                            selectedSpecies.isNotEmpty ? selectedSpecies : null,
                        onChanged: (value) {
                          setState(() {
                            selectedSpecies = value!;
                            if (selectedSpecies == 'Bovine') {
                              opdNumberPrefix = 'B-';
                            } else if (selectedSpecies == 'Porcine') {
                              opdNumberPrefix = 'P-';
                            } else if (selectedSpecies == 'Canine') {
                              opdNumberPrefix = 'C-';
                            } else if (selectedSpecies == 'Feline') {
                              opdNumberPrefix = 'F-';
                            } else if (selectedSpecies == 'Caprine') {
                              opdNumberPrefix = 'Cap-';
                            } else if (selectedSpecies == 'Lagomorphs') {
                              opdNumberPrefix = 'L-';
                            } else if (selectedSpecies == 'Equine') {
                              opdNumberPrefix = 'E-';
                            } else {
                              opdNumberPrefix = '';
                            }
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Canine',
                            child: Text('Canine'),
                          ),
                          DropdownMenuItem(
                            value: 'Feline',
                            child: Text('Feline'),
                          ),
                          DropdownMenuItem(
                            value: 'Bovine',
                            child: Text('Bovine'),
                          ),
                          DropdownMenuItem(
                            value: 'Porcine',
                            child: Text('Porcine'),
                          ),
                          DropdownMenuItem(
                            value: 'Caprine',
                            child: Text('Caprine'),
                          ),
                          DropdownMenuItem(
                            value: 'Lagomorphs',
                            child: Text('Lagomorphs'),
                          ),
                          DropdownMenuItem(
                            value: 'Equine',
                            child: Text('Equine'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Species',
                        ),
                      ),
                      TextFormField(
                        controller: opdNumberController,
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              opdNumber = '';
                            } else {
                              opdNumber = opdNumberPrefix + value;
                            }
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'OPD Number',
                          hintText: opdNumber.isNotEmpty ? opdNumber : '',
                          prefixText: opdNumberPrefix,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: sex.isNotEmpty ? sex : null,
                        onChanged: (value) {
                          setState(() {
                            sex = value!;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Sex',
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 200,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    CupertinoPicker(
                                      itemExtent: 32.0,
                                      onSelectedItemChanged: (selectedIndex) {
                                        setState(() {
                                          ageYears = (selectedIndex == 0)
                                              ? ''
                                              : (selectedIndex - 1)
                                                  .toString(); // Update the selected year
                                        });
                                      },
                                      children:
                                          List<Widget>.generate(101, (index) {
                                        if (index == 0) {
                                          return Text(
                                              'Years'); // Placeholder for years
                                        }
                                        return Text(
                                            '${(index - 1).toString()} years'); // Generate options for 0 to 100 years
                                      }),
                                    ),
                                    CupertinoPicker(
                                      itemExtent: 32.0,
                                      onSelectedItemChanged: (selectedIndex) {
                                        setState(() {
                                          ageMonths = (selectedIndex == 0)
                                              ? ''
                                              : (selectedIndex - 1)
                                                  .toString(); // Update the selected month
                                        });
                                      },
                                      children:
                                          List<Widget>.generate(13, (index) {
                                        if (index == 0) {
                                          return Text(
                                              'Months'); // Placeholder for months
                                        }
                                        return Text(
                                            '${(index - 1).toString()} months'); // Generate options for 0 to 12 months
                                      }),
                                    ),
                                    CupertinoPicker(
                                      itemExtent: 32.0,
                                      onSelectedItemChanged: (selectedIndex) {
                                        setState(() {
                                          ageDays = (selectedIndex == 0)
                                              ? ''
                                              : (selectedIndex - 1)
                                                  .toString(); // Update the selected day
                                        });
                                      },
                                      children:
                                          List<Widget>.generate(32, (index) {
                                        if (index == 0) {
                                          return Text(
                                              'Days'); // Placeholder for days
                                        }
                                        return Text(
                                            '${(index - 1).toString()} days'); // Generate options for 0 to 31 days
                                      }),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Text('Show Age Picker'),
                      ),
                      Text(
                        'Age: ${getFormattedAge()}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 80,
                        borderRadius: 20,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFffffff).withOpacity(0.2),
                            Color(0xFFFFFFFF).withOpacity(0.2),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFffffff).withOpacity(0.5),
                            Color((0xFFFFFFFF)).withOpacity(0.5),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Kilograms',
                                      textAlign: TextAlign.center,
                                    ),
                                    TextFormField(
                                      onChanged: (value) {
                                        // Validate and update the body weight in kilograms
                                        if (value.isEmpty ||
                                            double.tryParse(value) == null) {
                                          // Invalid input, set bodyWeightKg to null or any default value
                                          setState(() {
                                            bodyWeightKg = null;
                                          });
                                        } else {
                                          // Valid input, parse the value as a double and assign it to bodyWeightKg
                                          setState(() {
                                            bodyWeightKg = double.parse(value);
                                          });
                                        }
                                      },
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(
                                            r'[0-9.]')), // Only allow numbers and dot
                                      ],
                                      decoration: InputDecoration(
                                        labelText: '',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Grams',
                                      textAlign: TextAlign.center,
                                    ),
                                    TextFormField(
                                      onChanged: (value) {
                                        // Validate and update the body weight in grams
                                        if (value.isEmpty ||
                                            int.tryParse(value) == null) {
                                          // Invalid input, set bodyWeightGm to null or any default value
                                          setState(() {
                                            bodyWeightGm = null;
                                          });
                                        } else {
                                          // Valid input, parse the value as an integer and assign it to bodyWeightGm
                                          setState(() {
                                            bodyWeightGm = int.parse(value);
                                          });
                                        }
                                      },
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(
                                            r'[0-9]')), // Only allow numbers
                                      ],
                                      decoration: InputDecoration(
                                        labelText: '',
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Body Weight: ${((bodyWeightKg ?? 0) + (bodyWeightGm ?? 0) / 1000).toStringAsFixed(2)} kg',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 80,
                        borderRadius: 20,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFffffff).withOpacity(0.2),
                            Color(0xFFFFFFFF).withOpacity(0.2),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFffffff).withOpacity(0.5),
                            Color((0xFFFFFFFF)).withOpacity(0.5),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: temperatureWidth,
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      temperature = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Temperature',
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  showUnitDropdown = true;
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: 200,
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            CupertinoPicker(
                                              itemExtent: 32.0,
                                              onSelectedItemChanged:
                                                  (selectedIndex) {
                                                setState(() {
                                                  unit = units[selectedIndex];
                                                  showUnitDropdown = false;
                                                });
                                              },
                                              children: units
                                                  .map((unit) => Text(unit))
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: unitWidth,
                                  child: Text(
                                    unit.isNotEmpty ? unit : 'Select Unit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Temperature: $temperature $unit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: GlassmorphicContainer(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.2,
                              borderRadius: 20,
                              blur: 20,
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFffffff).withOpacity(0.1),
                                  Color(0xFFFFFFFF).withOpacity(0.05),
                                ],
                                stops: [
                                  0.1,
                                  1,
                                ],
                              ),
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFffffff).withOpacity(0.5),
                                  Color((0xFFFFFFFF)).withOpacity(0.5),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Heart Rate',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              heartRate = '';
                                            });
                                          },
                                          child: Text(
                                            'Reset',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showHeartRatePicker = true;
                                          showPulseRatePicker = false;
                                        });
                                        _showHeartRatePicker();
                                      },
                                      child: Text(
                                        heartRate.isNotEmpty
                                            ? heartRate
                                            : 'Select Heart Rate',
                                      ),
                                    ),
                                    if (showHeartRatePicker)
                                      CupertinoPicker(
                                        itemExtent: 32.0,
                                        onSelectedItemChanged: (selectedIndex) {
                                          setState(() {
                                            if (selectedIndex == 0) {
                                              heartRate = 'None';
                                            } else {
                                              heartRate = (selectedIndex + 29)
                                                  .toString();
                                            }
                                            showHeartRatePicker = false;
                                          });
                                        },
                                        children: [
                                          Text('None'),
                                          ...List<Widget>.generate(121,
                                              (index) {
                                            return Text(
                                                '${index + 30} beats per minute');
                                          }),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: GlassmorphicContainer(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.2,
                              borderRadius: 20,
                              blur: 20,
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFffffff).withOpacity(0.1),
                                  Color(0xFFFFFFFF).withOpacity(0.05),
                                ],
                                stops: [
                                  0.1,
                                  1,
                                ],
                              ),
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFffffff).withOpacity(0.5),
                                  Color((0xFFFFFFFF)).withOpacity(0.5),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pulse Rate',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              pulseRate = '';
                                            });
                                          },
                                          child: Text(
                                            'Reset',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showPulseRatePicker = true;
                                          showHeartRatePicker = false;
                                        });
                                        _showPulseRatePicker();
                                      },
                                      child: Text(
                                        pulseRate.isNotEmpty
                                            ? pulseRate
                                            : 'Select Pulse Rate',
                                      ),
                                    ),
                                    if (showPulseRatePicker)
                                      CupertinoPicker(
                                        itemExtent: 32.0,
                                        onSelectedItemChanged: (selectedIndex) {
                                          setState(() {
                                            if (selectedIndex == 0) {
                                              pulseRate = 'None';
                                            } else {
                                              pulseRate = (selectedIndex + 29)
                                                  .toString();
                                            }
                                            showPulseRatePicker = false;
                                          });
                                        },
                                        children: [
                                          Text('None'),
                                          ...List<Widget>.generate(121,
                                              (index) {
                                            return Text(
                                                '${index + 30} per minute');
                                          }),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: hasVaccination,
                                onChanged: (value) {
                                  setState(() {
                                    hasVaccination = value!;
                                  });
                                },
                              ),
                              Text('Vaccination'),
                              SizedBox(width: 10),
                              if (hasVaccination)
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2022),
                                        lastDate: DateTime.now(),
                                      );
                                      setState(() {
                                        this.vaccinationDate = selectedDate;
                                      });
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                      ),
                                      child: Text(
                                        vaccinationDate != null
                                            ? '${vaccinationDate?.year}-${vaccinationDate?.month}-${vaccinationDate?.day}'
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: vaccinationDate != null
                                              ? Colors.black
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: hasDeworming,
                                onChanged: (value) {
                                  setState(() {
                                    hasDeworming = value!;
                                  });
                                },
                              ),
                              Text('Deworming'),
                              SizedBox(width: 10),
                              if (hasDeworming)
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2022),
                                        lastDate: DateTime.now(),
                                      );
                                      setState(() {
                                        this.dewormingDate = selectedDate;
                                      });
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                      ),
                                      child: Text(
                                        dewormingDate != null
                                            ? '${dewormingDate?.year}-${dewormingDate?.month}-${dewormingDate?.day}'
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: dewormingDate != null
                                              ? Colors.black
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          TextFormField(
                            onChanged: (value) {
                              symptoms = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Symptoms',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return TreatmentDialog(
                                    onTreatmentSelected:
                                        handleTreatmentSelected,
                                    previousTreatments: treatments,
                                  );
                                },
                              );
                            },
                            child: TextFormField(
                              enabled: false,
                              controller: treatmentController,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: 'Treatment',
                              ),
                            ),
                          ),
                          TextFormField(
                            onChanged: (value) {
                              advice = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Advice',
                            ),
                          ),
                          if (showPregnancyOption)
                            Row(
                              children: [
                                Checkbox(
                                  value: isPregnant,
                                  onChanged: (value) {
                                    setState(() {
                                      isPregnant = value!;
                                    });
                                  },
                                ),
                                Text('Pregnant'),
                                SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Pregnancy Duration'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child:
                                                        DropdownButtonFormField<
                                                            int>(
                                                      value:
                                                          null, // Update initial value to null
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          pregnancyDays =
                                                              newValue!;
                                                        });
                                                      },
                                                      items: List.generate(
                                                        31,
                                                        (index) =>
                                                            DropdownMenuItem<
                                                                int>(
                                                          value: index + 1,
                                                          child: Text(
                                                              (index + 1)
                                                                  .toString()),
                                                        ),
                                                      ).toList(),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Days',
                                                        hintText: 'Select days',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        DropdownButtonFormField<
                                                            int>(
                                                      value:
                                                          null, // Update initial value to null
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          pregnancyMonths =
                                                              newValue!;
                                                        });
                                                      },
                                                      items: List.generate(
                                                        12,
                                                        (index) =>
                                                            DropdownMenuItem<
                                                                int>(
                                                          value: index + 1,
                                                          child: Text(
                                                              (index + 1)
                                                                  .toString()),
                                                        ),
                                                      ).toList(),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Months',
                                                        hintText:
                                                            'Select months',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        DropdownButtonFormField<
                                                            int>(
                                                      value:
                                                          null, // Update initial value to null
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          pregnancyYears =
                                                              newValue!;
                                                        });
                                                      },
                                                      items: List.generate(
                                                        5,
                                                        (index) =>
                                                            DropdownMenuItem<
                                                                int>(
                                                          value: index + 1,
                                                          child: Text(
                                                              (index + 1)
                                                                  .toString()),
                                                        ),
                                                      ).toList(),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Years',
                                                        hintText:
                                                            'Select years',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    pregnancyDuration =
                                                        '$pregnancyYears years $pregnancyMonths months $pregnancyDays days';
                                                    pregnancyController.text =
                                                        pregnancyDuration;
                                                  });
                                                  Navigator.pop(context, {
                                                    'days': pregnancyDays,
                                                    'months': pregnancyMonths,
                                                    'years': pregnancyYears,
                                                  });
                                                },
                                                child: Text('Save'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          pregnancyMonths = value['months'];

                                          if (value['years'] != 0) {
                                            pregnancyYears = value['years'];
                                            pregnancyDuration =
                                                '$pregnancyYears years ';
                                          } else {
                                            pregnancyDuration = '';
                                          }

                                          if (value['months'] != 0) {
                                            pregnancyDuration +=
                                                '$pregnancyMonths months ';
                                          }

                                          if (value['days'] != 0) {
                                            pregnancyDays = value['days'];
                                            pregnancyDuration +=
                                                '$pregnancyDays days';
                                          }

                                          pregnancyController.text =
                                              pregnancyDuration;
                                        });
                                      });
                                    },
                                    child: TextFormField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        labelText: 'Pregnancy',
                                        hintText: 'Select Pregnancy Duration',
                                      ),
                                      controller: pregnancyController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Map<String, dynamic> formData = {
                            'selectedDate': selectedDate,
                            'selectedSource': selectedSource,
                            'selectedDepartment': selectedDepartment,
                            'selectedSpecies': selectedSpecies,
                            'opdNumber': opdNumber,
                            'sex': sex,
                            'bodyWeightKg': bodyWeightKg,
                            'bodyWeightGm': bodyWeightGm,
                            'temperature': temperature,
                            'heartRate': heartRate,
                            'pulseRate': pulseRate,
                            'hasVaccination': hasVaccination,
                            'vaccinationDate': vaccinationDate,
                            'hasDeworming': hasDeworming,
                            'dewormingDate': dewormingDate,
                            'symptoms': symptoms,
                            'treatments': treatments,
                            'advice': advice,
                            'isPregnant': isPregnant,
                            'pregnancyDuration': pregnancyDuration,
                          };

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PreprocessScreen(formData: formData),
                            ),
                          );
                        },
                        child: Text('Submit'),
                      ),
                      MyFloatingActionButton(
                        onResetPressed: _resetForm,
                        opdNumber: opdNumber,
                        species: selectedSpecies,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyForm(),
  ));
}
