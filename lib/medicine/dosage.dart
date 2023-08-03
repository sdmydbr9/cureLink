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
        primaryColor: Color.fromARGB(
            255, 0, 64, 221), // Set your desired active color here
      ),
      home: MedicationFormScreen(),
    );
  }
}

class MedicationFormScreen extends StatefulWidget {
  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

// Controllers for dosage and body weight fields
List<TextEditingController> dosageControllers = [];
List<TextEditingController> bodyWeightControllers = [];

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  String _selectedCategory = '';
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
    'Caprine',
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

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> presentationControllers = [];
  List<TextEditingController> concentrationControllers = [];

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

      // Save dosage data from controllers to dosageList
      for (int i = 0; i < dosageControllers.length; i++) {
        dosageList[i]['dosage'] = dosageControllers[i].text;
        dosageList[i]['bodyWeight'] = bodyWeightControllers[i].text;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessDosageScreen(
            dosageList: dosageList,
            medicationList: medicationList,
            category: _selectedCategory, // Pass the selected category here
            name: _nameTextController.text, // Pass the entered name here
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

    // Initialize the controllers for the newly added medication row
    nameControllers.add(TextEditingController());
    presentationControllers.add(TextEditingController());
    concentrationControllers.add(TextEditingController());
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
      value: _selectedCategory, // Use the selected category here
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!; // Update the selected category
        });
      },
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

  Widget _buildDosageTable() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dosageList.length,
      itemBuilder: (context, index) {
        // Initialize controllers for each row
        if (dosageControllers.length <= index) {
          dosageControllers.add(TextEditingController());
        }
        if (bodyWeightControllers.length <= index) {
          bodyWeightControllers.add(TextEditingController());
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Dosage Row ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      removeDosageRow(index);
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pets, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            decoration: InputDecoration(labelText: 'Species'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: dosageControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        hintText: 'Enter dosage',
                        prefixIcon:
                            Icon(Icons.local_hospital, color: Colors.grey),
                      ),
                      keyboardType:
                          TextInputType.text, // Allow text input for ranges
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a dosage';
                        }

                        // Regular expression to check if the input matches the required format
                        RegExp dosagePattern =
                            RegExp(r'^(\d+(\.\d+)?|\d+-\d+)$');

                        if (!dosagePattern.hasMatch(value)) {
                          return 'Invalid dosage format. Please use a single number, decimal number, or a range (e.g., 5-10)';
                        }

                        // You can add additional checks for valid ranges, e.g., check if the range is increasing.

                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          dosageList[index]['dosage'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.format_list_numbered, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            decoration: InputDecoration(labelText: 'Unit'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: bodyWeightControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Body Weight',
                        hintText: 'Enter body weight',
                        prefixIcon:
                            Icon(Icons.accessibility, color: Colors.grey),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a body weight';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          dosageList[index]['bodyWeight'] = value;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.line_weight, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            decoration:
                                InputDecoration(labelText: 'Weight Unit'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            decoration: InputDecoration(
                              labelText: 'Route of Administration',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationTable() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: medicationList.length,
      itemBuilder: (context, index) {
        // Initialize the controllers for each medication row
        if (nameControllers.length <= index) {
          nameControllers.add(TextEditingController());
        }
        if (presentationControllers.length <= index) {
          presentationControllers.add(TextEditingController());
        }
        if (concentrationControllers.length <= index) {
          concentrationControllers.add(TextEditingController());
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Medication Row ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      removeMedicationRow(index);
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: nameControllers[index], // Use the controller
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter name',
                        prefixIcon:
                            Icon(Icons.medical_services, color: Colors.grey),
                      ),
                      onSaved: (value) {
                        medicationList[index]['name'] = value;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller:
                          concentrationControllers[index], // Use the controller
                      decoration: InputDecoration(
                        labelText: 'Concentration',
                        hintText: 'Enter concentration',
                        prefixIcon:
                            Icon(Icons.format_color_reset, color: Colors.grey),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) {
                        medicationList[index]['concentration'] = value;
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.track_changes, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            decoration: InputDecoration(
                                labelText: 'Concentration Unit'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller:
                          presentationControllers[index], // Use the controller
                      decoration: InputDecoration(
                        labelText: 'Presentation',
                        hintText: 'Enter presentation',
                        prefixIcon:
                            Icon(Icons.local_pharmacy, color: Colors.grey),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) {
                        medicationList[index]['presentation'] = value;
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.line_weight, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: medicationList[index]['presentationUnit'],
                            onChanged: (value) {
                              setState(() {
                                medicationList[index]['presentationUnit'] =
                                    value;
                              });
                            },
                            items: medUnitList.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            decoration:
                                InputDecoration(labelText: 'Presentation Unit'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_showReconstitution)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Reconstitution: ${medicationList[index]['reconstitutionValue'] != null ? '${medicationList[index]['reconstitutionValue']} ${medicationList[index]['reconstitutionUnit']}' : 'N/A'}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showReconstitutionDialog(index),
                            child: Text('Edit'),
                          ),
                        ],
                      ),
                    SizedBox(height: 8),
                    if (medicationList[index]['image'] != null)
                      Container(
                        height: 100,
                        width: 100,
                        child: kIsWeb
                            ? Image.memory(medicationList[index]['image'])
                            : Image.file(medicationList[index]['image']),
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showImageSelectionDialog(index),
                      child: Text('Select Image'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Medication Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildCategoryField(),
            SizedBox(height: 16.0),
            _buildNameField(),
            _isNameAvailable != null && !_isNameAvailable!
                ? Text(
                    'The medication name already exists.',
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox(),
            SizedBox(height: 16.0),
            Text('Dosage:'),
            _buildDosageTable(),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  addDosageRow();
                });
              },
              child: Icon(CupertinoIcons.add_circled),
            ),
            SizedBox(height: 16.0),
            Text('Medication:'),
            _buildMedicationTable(),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  addMedicationRow();
                });
              },
              child: Icon(CupertinoIcons.add_circled),
            ),
            SizedBox(height: 16.0),
            CupertinoButton.filled(
              onPressed: () => _processData(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
