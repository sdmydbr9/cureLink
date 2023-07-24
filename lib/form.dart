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
import 'pregnancy.dart';
import 'package:blur/blur.dart';

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
  List<String> sourceOptions = [
    'TVCC',
    'State Veterinary Hospital',
    'Dispensary',
    'Private',
    'Others',
  ];
  List<String> departmentOptions = [
    'Medicine',
    'Surgery',
    'Gynecology',
  ];
  List<String> speciesOptions = [
    'Canine',
    'Feline',
    'Bovine',
    'Porcine',
    'Caprine',
    'Lagomorphs',
    'Equine',
  ];
  List<String> unitOptions = ['°C', '°F', 'K'];

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

  Future<void> _selectDate(BuildContext context) async {
    // Get the current date
    final DateTime currentDate = DateTime.now();

    // Store the picked date in a temporary variable
    DateTime pickedDate = currentDate;

    // Show the modal popup with a glass-like transparent background
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Opacity(
          opacity:
              0.7, // Adjust the opacity value (0.0 to 1.0) for the desired transparency
          child: Container(
            color: Colors
                .transparent, // Use a transparent color for the background
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 10, sigmaY: 10), // Adjust the blur strength as needed
              child: Container(
                height: 300.0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: pickedDate,
                  minimumDate:
                      DateTime(1900), // Set the minimum selectable date
                  maximumDate: currentDate, // Set the maximum selectable date
                  onDateTimeChanged: (DateTime newDate) {
                    pickedDate = newDate;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    // Update the selected date with the picked date
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _updateOPDNumberPrefix() {
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
  }

  Widget _buildTemperatureSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormSection(
        children: [
          CupertinoFormRow(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    onChanged: (value) {
                      setState(() {
                        temperature = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                    placeholder: 'Temperature',
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    groupValue: unit,
                    onValueChanged: (value) {
                      setState(() {
                        unit = value as String;
                      });
                    },
                    children: unitOptions.asMap().map((index, unit) {
                      return MapEntry<String, Widget>(
                        unit,
                        Text(unit),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    return CupertinoFormSection(
      header: GestureDetector(
        onTap: () {
          _showCupertinoPicker(sourceOptions, selectedSource, 'Source',
              (newValue) {
            setState(() {
              selectedSource = newValue;
            });
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors
                .lightBackgroundGray, // You can customize the background color here
            borderRadius: BorderRadius.circular(
                8.0), // Adjust the radius for the rounded corners
          ),
          child: Text(
            selectedSource.isNotEmpty ? 'Source: $selectedSource' : 'Source',
            style: const TextStyle(
              fontSize: 16.0,
              color: CupertinoColors
                  .black, // You can customize the text color here
            ),
          ),
        ),
      ),
      children: [], // Add other form elements inside this list if needed
    );
  }

  Widget _buildDepartmentSection() {
    return CupertinoFormSection(
      header: GestureDetector(
        onTap: () {
          _showCupertinoPicker(
            departmentOptions,
            selectedDepartment,
            'Department',
            (newValue) {
              setState(() {
                selectedDepartment = newValue;
              });
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors
                .lightBackgroundGray, // You can customize the background color here
            borderRadius: BorderRadius.circular(
                8.0), // Adjust the radius for the rounded corners
          ),
          child: Text(
            selectedDepartment.isNotEmpty
                ? 'Department: $selectedDepartment'
                : 'Department',
            style: const TextStyle(
              fontSize: 16.0,
              color: CupertinoColors
                  .black, // You can customize the text color here
            ),
          ),
        ),
      ),
      children: [], // Add other form elements inside this list if needed
    );
  }

  Widget _buildSpeciesSection() {
    return CupertinoFormSection(
      header: GestureDetector(
        onTap: () {
          _showCupertinoPicker(
            speciesOptions,
            selectedSpecies,
            'Species',
            (newValue) {
              setState(() {
                selectedSpecies = newValue;
                _updateOPDNumberPrefix(); // Call the method to update the OPD number prefix
              });
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors
                .lightBackgroundGray, // You can customize the background color here
            borderRadius: BorderRadius.circular(
                8.0), // Adjust the radius for the rounded corners
          ),
          child: Text(
            selectedSpecies.isNotEmpty
                ? 'Species: $selectedSpecies'
                : 'Species',
            style: const TextStyle(
              fontSize: 16.0,
              color: CupertinoColors
                  .black, // You can customize the text color here
            ),
          ),
        ),
      ),
      children: [], // Add other form elements inside this list if needed
    );
  }

  void _showCupertinoPicker(List<String> options, String selectedValue,
      String title, void Function(String) onValueChanged) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {}, // Prevent taps from dismissing the modal
          child: Container(
            height: 200.0,
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                onValueChanged(options[index]);
              },
              children: options.map((option) => Text(option)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseRateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormSection(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showPulseRatePicker = true;
                  });
                  _showPulseRatePicker();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoFormRow(
                    child: Text(
                      pulseRate.isNotEmpty ? pulseRate : 'Select pulse Rate',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: CupertinoColors
                            .black, // You can customize the text color here
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    pulseRate = '';
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    CupertinoIcons.refresh,
                    size: 20.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormSection(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showHeartRatePicker = true;
                  });
                  _showHeartRatePicker();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoFormRow(
                    child: Text(
                      heartRate.isNotEmpty ? heartRate : 'Select Heart Rate',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: CupertinoColors
                            .black, // You can customize the text color here
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    heartRate = '';
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    CupertinoIcons.refresh,
                    size: 20.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDewormingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormRow(
        child: Row(
          children: [
            CupertinoSwitch(
              value: hasDeworming,
              onChanged: (value) {
                setState(() {
                  hasDeworming = value;
                });
              },
            ),
            const Text(
              'Deworming',
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors
                    .black, // You can customize the text color here
              ),
            ),
            const SizedBox(width: 10),
            if (hasDeworming)
              GestureDetector(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoFormRow(
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
                    prefix: const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: CupertinoColors
                            .black, // You can customize the text color here
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOPDNumberSection() {
    return CupertinoFormSection(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: CupertinoColors
                      .lightBackgroundGray, // You can customize the background color here
                  borderRadius: BorderRadius.circular(
                      8.0), // Adjust the radius for the rounded corners
                ),
                child: const Text(
                  'OPD Number',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors
                        .black, // You can customize the text color here
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CupertinoTextField(
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
                      placeholder: 'OPD Number',
                      prefix: Text(opdNumberPrefix),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSexSection() {
    return CupertinoFormSection(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors
                .lightBackgroundGray, // You can customize the background color here
            borderRadius: BorderRadius.circular(
                8.0), // Adjust the radius for the rounded corners
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sex',
                style: TextStyle(
                  fontSize: 16.0,

                  color: CupertinoColors
                      .black, // You can customize the text color here
                ),
              ),
              CupertinoFormRow(
                child: CupertinoSlidingSegmentedControl(
                  groupValue: sex.isNotEmpty ? sex : null,
                  onValueChanged: (value) {
                    setState(() {
                      sex = value as String;
                    });
                  },
                  children: const {
                    'Male': Text('Male'),
                    'Female': Text('Female'),
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyWeightSection() {
    return CupertinoFormSection(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors.lightBackgroundGray,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CupertinoFormRow(
            child: Row(
              children: [
                Text(
                  getFormattedBodyWeight(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: CupertinoTextField(
                    onChanged: (value) {
                      if (value.isEmpty || double.tryParse(value) == null) {
                        setState(() {
                          bodyWeightKg = null;
                        });
                      } else {
                        setState(() {
                          bodyWeightKg = double.parse(value);
                        });
                      }
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    placeholder: 'Kilograms',
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoTextField(
                    onChanged: (value) {
                      if (value.isEmpty || int.tryParse(value) == null) {
                        setState(() {
                          bodyWeightGm = null;
                        });
                      } else {
                        setState(() {
                          bodyWeightGm = int.parse(value);
                        });
                      }
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    placeholder: 'Grams',
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String getFormattedBodyWeight() {
    if (bodyWeightKg == null && bodyWeightGm == null) {
      return 'Body Weight: ';
    } else {
      double totalWeight = (bodyWeightKg ?? 0) + (bodyWeightGm ?? 0) / 1000;
      return 'Body Weight: ${totalWeight.toStringAsFixed(2)} kg';
    }
  }

  void _showBodyWeightPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (selectedIndex) {
                  setState(() {
                    if (selectedIndex == 0) {
                      bodyWeightKg = null;
                    } else {
                      bodyWeightKg = selectedIndex.toDouble();
                    }
                  });
                },
                children: List<Widget>.generate(101, (index) {
                  return Text('${index.toString()}');
                }),
              ),
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (selectedIndex) {
                  setState(() {
                    if (selectedIndex == 0) {
                      bodyWeightGm = null;
                    } else {
                      bodyWeightGm = selectedIndex - 1;
                    }
                  });
                },
                children: List<Widget>.generate(1000, (index) {
                  return Text('${index.toString()}');
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSymptomsSection() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormSection(
        decoration: BoxDecoration(
          color: Colors
              .transparent, // Remove inner background color to maintain consistency
          border: Border.all(
            color: CupertinoColors.systemGrey3,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        children: [
          CupertinoFormRow(
            child: CupertinoTextFormFieldRow(
              onChanged: (value) {
                setState(() {
                  symptoms = value;
                });
              },
              placeholder: 'Symptoms',
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent, // Remove inner border
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormSection(
        decoration: BoxDecoration(
          color: Colors
              .transparent, // Remove inner background color to maintain consistency
          border: Border.all(
            color: CupertinoColors.systemGrey3,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        children: [
          CupertinoFormRow(
            child: CupertinoTextFormFieldRow(
              onChanged: (value) {
                setState(() {
                  advice = value;
                });
              },
              placeholder: 'Advice',
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.transparent), // Remove inner border
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSection() {
    return CupertinoFormSection(
      header: GestureDetector(
        onTap: () {
          _showAgePicker();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: CupertinoColors
                .lightBackgroundGray, // You can customize the background color here
            borderRadius: BorderRadius.circular(
                8.0), // Adjust the radius for the rounded corners
          ),
          child: Text(
            'Age: ${getFormattedAge()}',
            style: const TextStyle(
              fontSize: 18.0,
              color: CupertinoColors
                  .black, // You can customize the text color here
            ),
          ),
        ),
      ),
      children: [], // Add other form elements inside this list if needed
    );
  }

  void _showAgePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (selectedIndex) {
                    setState(() {
                      ageYears = (selectedIndex == 0)
                          ? ''
                          : (selectedIndex - 1)
                              .toString(); // Update the selected year
                    });
                  },
                  children: List<Widget>.generate(101, (index) {
                    if (index == 0) {
                      return const Text('Years'); // Placeholder for years
                    }
                    return Text(
                        '${(index - 1).toString()} years'); // Generate options for 0 to 100 years
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (selectedIndex) {
                    setState(() {
                      ageMonths = (selectedIndex == 0)
                          ? ''
                          : (selectedIndex - 1)
                              .toString(); // Update the selected month
                    });
                  },
                  children: List<Widget>.generate(13, (index) {
                    if (index == 0) {
                      return const Text('Months'); // Placeholder for months
                    }
                    return Text(
                        '${(index - 1).toString()} months'); // Generate options for 0 to 12 months
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (selectedIndex) {
                    setState(() {
                      ageDays = (selectedIndex == 0)
                          ? ''
                          : (selectedIndex - 1)
                              .toString(); // Update the selected day
                    });
                  },
                  children: List<Widget>.generate(32, (index) {
                    if (index == 0) {
                      return const Text('Days'); // Placeholder for days
                    }
                    return Text(
                        '${(index - 1).toString()} days'); // Generate options for 0 to 31 days
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getFormattedAge() {
    String formattedAge = '';

    if (ageYears.isNotEmpty) {
      formattedAge += '$ageYears year${ageYears == '1' ? '' : 's'} ';
    }

    if (ageMonths.isNotEmpty) {
      formattedAge += '$ageMonths month${ageMonths == '1' ? '' : 's'} ';
    }

    if (ageDays.isNotEmpty) {
      formattedAge += '$ageDays day${ageDays == '1' ? '' : 's'}';
    }

    if (formattedAge.isEmpty) {
      formattedAge =
          'Select age'; // Display a default message if no age is selected
    }

    return formattedAge;
  }

  Widget _buildVaccinationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: CupertinoFormRow(
        child: Row(
          children: [
            CupertinoSwitch(
              value: hasVaccination,
              onChanged: (value) {
                setState(() {
                  hasVaccination = value;
                });
              },
            ),
            const Text(
              'Vaccination',
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors
                    .black, // You can customize the text color here
              ),
            ),
            const SizedBox(width: 10),
            if (hasVaccination)
              GestureDetector(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoFormRow(
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
                    prefix: const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: CupertinoColors
                            .black, // You can customize the text color here
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CupertinoColors
            .lightBackgroundGray, // You can customize the background color here
        borderRadius: BorderRadius.circular(
            8.0), // Adjust the radius for the rounded corners
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TreatmentDialog(
                onTreatmentSelected: handleTreatmentSelected,
                previousTreatments: treatments,
              );
            },
          ).then((value) {
            // The dialog has been closed and you can handle the value returned here
            // For example, you can update the treatmentController text here
            treatmentController.text = value ?? '';
          });
        },
        child: TextFormField(
          enabled: false,
          controller: treatmentController,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Treatment',
          ),
        ),
      ),
    );
  }

  Widget _buildSpeciesSegmentedControl() {
    return CupertinoSlidingSegmentedControl(
      groupValue: selectedSpecies.isNotEmpty ? selectedSpecies : null,
      onValueChanged: (value) {
        setState(() {
          selectedSpecies = value as String;
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
      children: const {
        'Canine': Text('Canine'),
        'Feline': Text('Feline'),
        'Bovine': Text('Bovine'),
        'Porcine': Text('Porcine'),
        'Caprine': Text('Caprine'),
        'Lagomorphs': Text('Lagomorphs'),
        'Equine': Text('Equine'),
      },
    );
  }

  void _openPregnancyDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return PregnancyDialog();
      },
    ).then((value) {
      if (value != null && value is Map<String, int>) {
        setState(() {
          pregnancyMonths = value['months'] ?? 0;

          if (value['years'] != null && value['years']! > 0) {
            pregnancyYears = value['years']!;
            pregnancyDuration = '$pregnancyYears years ';
          } else {
            pregnancyDuration = '';
          }

          if (pregnancyMonths > 0) {
            pregnancyDuration += '$pregnancyMonths months ';
          }

          if (value['days'] != null && value['days']! > 0) {
            pregnancyDays = value['days']!;
            pregnancyDuration += '$pregnancyDays days';
          }

          pregnancyController.text = pregnancyDuration;
        });
      }
    });
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
              const Text('None'),
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
              const Text('None'),
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
      'age': getFormattedAge(),
      'sex': sex,
      'bodyWeightKg': bodyWeightKg,
      'bodyWeightGm': bodyWeightGm,
      'temperature': temperature,
      'unit': unit,
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
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final layoutSpacing = isPortrait ? 16.0 : 32.0;
    final fontSize = isPortrait ? 16.0 : 20.0;

    final dateFormat = DateFormat('d MMMM yyyy');
    final formattedDate =
        selectedDate != null ? dateFormat.format(selectedDate!) : '';

    return Container(
      color: CupertinoColors.white,
      child: Container(
        // Remove the surrounding Padding widget

        child: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Medical Portal'),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: CupertinoTheme.of(context).textTheme.textStyle,
                child: Container(
                  color: Colors
                      .white, // Set the background color of the Container to white
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Text(
                            formattedDate.isNotEmpty
                                ? 'Date: $formattedDate'
                                : 'Select Date',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        color: Colors
                            .white, // Set the background color of the Column to white
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSourceSection(),

                            _buildDepartmentSection(),
                            _buildSpeciesSection(),
                            _buildAgeSection(),

                            _buildOPDNumberSection(),

                            _buildSexSection(),

                            _buildBodyWeightSection(),

                            _buildTemperatureSection(),

                            _buildHeartRateSection(),

                            _buildPulseRateSection(),

                            _buildVaccinationSection(),

                            _buildDewormingSection(),

                            _buildSymptomsSection(),

                            _buildTreatmentSection(),
                            _buildAdviceSection(),

                            // Conditionally add the Row for pregnancy based on showPregnancyOption
                            if (showPregnancyOption) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: CupertinoColors
                                      .lightBackgroundGray, // You can customize the background color here
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the radius for the rounded corners
                                ),
                                child: Row(
                                  children: [
                                    CupertinoSwitch(
                                      value: isPregnant,
                                      onChanged: (value) {
                                        setState(() {
                                          isPregnant = value;
                                        });
                                        if (isPregnant) {
                                          _openPregnancyDialog();
                                        }
                                      },
                                    ),
                                    const Text(
                                      'Pregnant',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: CupertinoColors
                                            .black, // You can customize the text color here
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          _openPregnancyDialog();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            pregnancyController.text.isNotEmpty
                                                ? pregnancyController.text
                                                : 'Select Pregnancy Duration',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: pregnancyController
                                                      .text.isNotEmpty
                                                  ? CupertinoColors.black
                                                  : CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // End of the Row for pregnancy

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
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
                              'unit': unit,
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
                          child: const Text('Submit'),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomLeft,
                        child: MyFloatingActionButton(
                          onResetPressed: _resetForm,
                          opdNumber: opdNumber,
                          species: selectedSpecies,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: MyForm(),
    ));
  }
}
