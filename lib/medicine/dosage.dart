import 'dart:io';
import 'process_dosage.dart';
import 'package:flutter/material.dart';
import '../index.dart';
import '../main.dart';
import 'api.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

import 'package:image_picker_web/image_picker_web.dart';

void main() => runApp(MedicationFormApp());

class MedicationFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicationFormScreen(),
    );
  }
}

class MedicationFormScreen extends StatefulWidget {
  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  bool _showReconstitution = false;
  bool? _isNameAvailable;
  TextEditingController _nameTextController = TextEditingController();

  List<String> speciesList = [
    'None',
    'Dogs',
    'Cats',
    'Cattle',
    'Sheep/Goat',
    'Horse',
    'Rabbits',
    'Avian',
    'Pigs'
  ];
  List<String> unitList = [
    'None',
    'mg',
    'kg',
    'g',
    'mcg',
    'ml',
    'stat',
  ];
  List<String> weightUnitList = [
    'None',
    'kg',
    'g',
  ];
  List<String> routeList = [
    'None',
    'Oral',
    'Intramuscular',
    'Slow IV',
    'Subcutaneous',
    'Intravenous',
    'Topical',
  ];
  List<String> typeList = [
    'None',
    'Inj',
    'syrup',
    'Vial',
    'Reconstitutable injectables',
    'Tab',
    'Shampoo',
  ];
  List<String> medUnitList = [
    'None',
    'ml',
    'mg',
    'mg/ml',
    '% w/v',
  ];
  List<String> presentationUnitList = [
    'None',
    'ml',
    'mg',
    'mg/ml',
    '% w/v',
  ];
  List<String> valueUnitList = [
    'mg',
    'ml',
    'l',
  ];
  List<Map<String, dynamic>> dosageList = [];
  List<Map<String, dynamic>> medicationList = [];

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    addDosageRow();
    addMedicationRow();

    _nameFocusNode.addListener(() => _handleNameFieldFocusChange());
  }

  void _processData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessDosageScreen(
            dosageList: dosageList,
            medicationList: medicationList,
          ),
        ),
      );
    }
  }

  void _showReconstitutionDialog(int index) {
    if (medicationList[index]['type'] == 'Reconstitutable injectables') {
      TextEditingController _reconstitutionValueController =
          TextEditingController();
      String? _reconstitutionUnit;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reconstitution'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value:'),
                TextFormField(
                  controller: _reconstitutionValueController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Value Unit:'),
                DropdownButtonFormField<String>(
                  value: _reconstitutionUnit,
                  onChanged: (value) {
                    setState(() {
                      _reconstitutionUnit = value;
                    });
                  },
                  items: valueUnitList.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    medicationList[index]['reconstitutionValue'] =
                        _reconstitutionValueController.text;
                    medicationList[index]['reconstitutionUnit'] =
                        _reconstitutionUnit;
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
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
  }

  void addDosageRow() {
    dosageList.add({
      'species': null,
      'dosage': null,
      'unit': null,
      'bodyWeight': null,
      'weightUnit': null,
      'route': null,
    });
  }

  void removeDosageRow(int index) {
    dosageList.removeAt(index);
  }

  void addMedicationRow() {
    medicationList.add({
      'type': null,
      'name': null,
      'concentration': null,
      'unit': null,
      'presentation': null,
      'presentationUnit': null,
      'reconstitutionValue': null,
      'reconstitutionUnit': null,
      'image': null, // Add 'image' field to each medication entry
    });
  }

  void _showImageSelectionDialog(int index) async {
    if (kIsWeb) {
      // For web platform, use the image_picker_web package
      Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

      if (imageBytes != null) {
        setState(() {
          medicationList[index]['image'] = imageBytes;
        });
      }
    } else {
      // For other platforms (iOS and Android), use the regular image_picker package
      final imagePicker = ImagePicker();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedImage = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedImage != null) {
                      File imageFile = File(pickedImage.path);
                      setState(() {
                        medicationList[index]['image'] = imageFile;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedImage = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedImage != null) {
                      File imageFile = File(pickedImage.path);
                      setState(() {
                        medicationList[index]['image'] = imageFile;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void removeMedicationRow(int index) {
    medicationList.removeAt(index);
  }

  Future<bool> checkNameAvailability(String name) async {
    return await MedicationAPI.checkNameAvailability(name);
  }

  void _handleNameFieldFocusChange() async {
    if (!_nameFocusNode.hasFocus && _nameTextController.text.isNotEmpty) {
      String name = _nameTextController.text;
      bool isAvailable = await checkNameAvailability(name);
      setState(() {
        _isNameAvailable = !isAvailable;
      });

      if (!_isNameAvailable!) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Medication Name'),
              content: Text('The medication name already exists.'),
              actions: [
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
      }
    }
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Category'),
      value: '',
      onChanged: (value) {},
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('None'),
        ),
        DropdownMenuItem(
          value: 'analgesics',
          child: Text('Analgesics'),
        ),
        DropdownMenuItem(
          value: 'antibiotics',
          child: Text('Antibiotics'),
        ),
        DropdownMenuItem(
          value: 'antiseptics',
          child: Text('Antiseptics'),
        ),
        DropdownMenuItem(
          value: 'NSAIDs',
          child: Text('NSAIDs'),
        ),
        DropdownMenuItem(
          value: 'anthelmintics',
          child: Text('Anthelmintics'),
        ),
        DropdownMenuItem(
          value: 'antiemetics',
          child: Text('Anti-Emetics'),
        ),
        DropdownMenuItem(
          value: 'general_anesthesia',
          child: Text('General Anesthesia'),
        ),
        DropdownMenuItem(
          value: 'local_anesthesia',
          child: Text('Local Anesthesia'),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      focusNode: _nameFocusNode,
      controller: _nameTextController,
    );
  }

  Widget build(BuildContext context) {
    // Get the screen size using media queries
    final mediaQueryData = MediaQuery.of(context);
    final screenWidth = mediaQueryData.size.width;
    final screenHeight = mediaQueryData.size.height;

    // Calculate the dynamic size by multiplying with 0.9 (90%)
    final dynamicWidth = screenWidth * 0.9;
    final dynamicHeight = screenHeight * 0.9;

    // Calculate the dynamic text size based on the screen width
    final dynamicTextSize = screenWidth * 0.02;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Medication Form',
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryField(),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    focusNode: _nameFocusNode,
                    controller: _nameTextController,
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                  Text(
                    'Dose Rate:',
                    style: TextStyle(
                      fontSize: dynamicTextSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: [
                        DataColumn(label: Text('Species')),
                        DataColumn(label: Text('Dosage')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Body Weight')),
                        DataColumn(label: Text('Weight Unit')),
                        DataColumn(label: Text('Route of Administration')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: List.generate(dosageList.length, (index) {
                        return DataRow(
                          cells: [
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: dosageList[index]['species'],
                                onChanged: (value) {
                                  setState(() {
                                    dosageList[index]['species'] = value;
                                  });
                                },
                                items: speciesList.map((species) {
                                  return DropdownMenuItem(
                                    value: species,
                                    child: Text(species),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Dosage',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onSaved: (value) {
                                  dosageList[index]['dosage'] = value;
                                },
                              ),
                            ),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: dosageList[index]['unit'],
                                onChanged: (value) {
                                  setState(() {
                                    dosageList[index]['unit'] = value;
                                  });
                                },
                                items: unitList.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Body Weight',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onSaved: (value) {
                                  dosageList[index]['bodyWeight'] = value;
                                },
                              ),
                            ),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: dosageList[index]['weightUnit'],
                                onChanged: (value) {
                                  setState(() {
                                    dosageList[index]['weightUnit'] = value;
                                  });
                                },
                                items: weightUnitList.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: dosageList[index]['route'],
                                onChanged: (value) {
                                  setState(() {
                                    dosageList[index]['route'] = value;
                                  });
                                },
                                items: routeList.map((route) {
                                  return DropdownMenuItem(
                                    value: route,
                                    child: Text(route),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    removeDosageRow(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        addDosageRow();
                      });
                    },
                    child: Icon(CupertinoIcons.add),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Medication details',
                    style: TextStyle(
                      fontSize: dynamicTextSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: [
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Concentration')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Presentation')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Reconstitution')),
                        DataColumn(label: Text('Image')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: List.generate(medicationList.length, (index) {
                        return DataRow(
                          cells: [
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: medicationList[index]['type'],
                                onChanged: (value) {
                                  setState(() {
                                    medicationList[index]['type'] = value;
                                    _showReconstitution =
                                        value == 'Reconstitutable injectables';
                                  });
                                },
                                items: typeList.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Name',
                                ),
                                onSaved: (value) {
                                  medicationList[index]['name'] = value;
                                },
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Concentration',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onSaved: (value) {
                                  medicationList[index]['concentration'] =
                                      value;
                                },
                              ),
                            ),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: medicationList[index]['unit'],
                                onChanged: (value) {
                                  setState(() {
                                    medicationList[index]['unit'] = value;
                                  });
                                },
                                items: medUnitList.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Presentation',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onSaved: (value) {
                                  medicationList[index]['presentation'] = value;
                                },
                              ),
                            ),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: medicationList[index]
                                    ['presentationUnit'],
                                onChanged: (value) {
                                  setState(() {
                                    medicationList[index]['presentationUnit'] =
                                        value;
                                  });
                                },
                                items: presentationUnitList.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              Visibility(
                                visible: _showReconstitution,
                                child: GestureDetector(
                                  onTap: () {
                                    _showReconstitutionDialog(index);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8.0),
                                      Text(
                                        medicationList[index]
                                                    ['reconstitutionValue'] !=
                                                null
                                            ? '${medicationList[index]['reconstitutionValue']} ${medicationList[index]['reconstitutionUnit']}'
                                            : 'N/A',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  _showImageSelectionDialog(index);
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.image),
                                    SizedBox(width: 8.0),
                                    Text('Select Image'),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    removeMedicationRow(index);
                                  });
                                },
                              ),
                            ),
                          ],

                          // Conditionally show the reconstitution dialog based on the type of medication
                          onSelectChanged: (isSelected) {
                            if (isSelected! &&
                                medicationList[index]['type'] ==
                                    'Reconstitutable injectables') {
                              _showReconstitutionDialog(index);
                            }
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        addMedicationRow();
                      });
                    },
                    child: Icon(CupertinoIcons.add),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _processData(context),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
