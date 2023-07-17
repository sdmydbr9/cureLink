import 'package:flutter/material.dart';
import '../index.dart';
import '../main.dart';
import 'api.dart';

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

    _nameFocusNode.addListener(_handleNameFieldFocusChange);
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
    });
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Medication Name'),
              content: Text('The medication name already exists.'),
              actions: [
                TextButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Form'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Login'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalPortalHomePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medication Form',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
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
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    focusNode: _nameFocusNode,
                    controller: _nameTextController,
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                  if (_isNameAvailable == true)
                    Text(
                      'Medication name is available.',
                      style: TextStyle(color: Colors.green),
                    ),
                  if (_isNameAvailable == false)
                    Text(
                      'Medication name already exists.',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 16.0),
                  Text(
                    'Dose Rate:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  DataTable(
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
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        addDosageRow();
                      });
                    },
                    child: Text('Add More'),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Medication Details:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                              GestureDetector(
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
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        addMedicationRow();
                      });
                    },
                    child: Text('Add More'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    },
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
