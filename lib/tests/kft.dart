import 'package:flutter/material.dart';
import 'package:cure_link/tests/process_kft.dart';

class KftPage extends StatefulWidget {
  final String opdNumber;
  final String species;

  KftPage({required this.opdNumber, required this.species});

  @override
  _KftPageState createState() => _KftPageState();
}

class _KftPageState extends State<KftPage> {
  String? _selectedSpecies;

  final TextEditingController _opdNumberController = TextEditingController();
  final TextEditingController _bunController = TextEditingController();
  final TextEditingController _creatinineController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();

  final Map<String, Map<String, String>> _normalRanges = {
    'canine': {
      'bun': '5-30',
      'creatinine': '0.5-1.8',
      'phosphorus': '2.5-6.0',
      'potassium': '3.5-5.8',
      'sodium': '135-150',
    },
    'equine': {
      'bun': '10-25',
      'creatinine': '1.2-2.4',
      'phosphorus': '2.5-6.0',
      'potassium': '3.5-5.5',
      'sodium': '135-145',
    },
    'bovine': {
      'bun': '10-30',
      'creatinine': '0.6-1.8',
      'phosphorus': '2.5-6.0',
      'potassium': '2.5-5.5',
      'sodium': '135-145',
    },
    'porcine': {
      'bun': '10-30',
      'creatinine': '0.8-2.0',
      'phosphorus': '2.5-7.0',
      'potassium': '3.0-6.0',
      'sodium': '140-150',
    },
    'avian': {
      'bun': '10-40',
      'creatinine': '0.6-1.8',
      'phosphorus': '2.5-6.0',
      'potassium': '2.5-5.5',
      'sodium': '140-160',
    },
    'caprine': {
      'bun': '15-45',
      'creatinine': '0.8-2.5',
      'phosphorus': '3.0-8.0',
      'potassium': '2.5-5.5',
      'sodium': '130-145',
    },
    'feline': {
      'bun': '20-45',
      'creatinine': '0.8-2.4',
      'phosphorus': '3.0-7.0',
      'potassium': '3.5-5.8',
      'sodium': '135-150',
    },
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _opdNumberController.dispose();
    _bunController.dispose();
    _creatinineController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.opdNumber.isNotEmpty) {
      _opdNumberController.text = widget.opdNumber;
    }

    final passedSpecies = widget.species.toLowerCase();
    _selectedSpecies = _normalRanges.keys.firstWhere(
      (species) => species.toLowerCase() == passedSpecies,
      orElse: () => 'select species',
    );
    if (_selectedSpecies == 'select species') {
      _selectedSpecies = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Veterinary Kidney Function Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (widget.species.isNotEmpty) ...[
              Text(
                'Species: ${widget.species}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            Form(
              key: _formKey, // Assign the GlobalKey to the Form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.species.isEmpty) ...[
                    const Text('Species:', style: TextStyle(fontSize: 16)),
                    DropdownButtonFormField<String>(
                      value: _selectedSpecies,
                      items: _buildSpeciesDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecies = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select Species',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a species';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('OPD Number:', style: TextStyle(fontSize: 16)),
                  TextFormField(
                    controller: _opdNumberController,
                    readOnly: widget.opdNumber.isNotEmpty,
                    decoration: const InputDecoration(
                      hintText: 'OPD Number',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'OPD Number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedSpecies != null) ...[
                    DataTable(
                      columns: [
                        DataColumn(label: Text('Kidney Parameter')),
                        DataColumn(label: Text('Data Entry')),
                        DataColumn(label: Text('Normal Range')),
                      ],
                      rows: _buildDataRows(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final bunValue = _bunController.text.trim();
                        final creatinineValue =
                            _creatinineController.text.trim();
                        final phosphorusValue =
                            _phosphorusController.text.trim();
                        final potassiumValue = _potassiumController.text.trim();
                        final sodiumValue = _sodiumController.text.trim();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessKftPage(
                              opdNumber: _opdNumberController.text.trim(),
                              species: _selectedSpecies!,
                              bun: bunValue,
                              creatinine: creatinineValue,
                              phosphorus: phosphorusValue,
                              potassium: potassiumValue,
                              sodium: sodiumValue,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSpeciesDropdownItems() {
    if (widget.species.isEmpty) {
      return const [
        DropdownMenuItem<String>(
          value: 'canine',
          child: Text('Canine'),
        ),
        DropdownMenuItem<String>(
          value: 'feline',
          child: Text('Feline'),
        ),
        DropdownMenuItem<String>(
          value: 'porcine',
          child: Text('Porcine'),
        ),
        DropdownMenuItem<String>(
          value: 'bovine',
          child: Text('Bovine'),
        ),
        DropdownMenuItem<String>(
          value: 'equine',
          child: Text('Equine'),
        ),
        DropdownMenuItem<String>(
          value: 'avian',
          child: Text('Avian'),
        ),
        DropdownMenuItem<String>(
          value: 'caprine',
          child: Text('Caprine'),
        ),
      ];
    } else {
      return [
        DropdownMenuItem<String>(
          value: widget.species.toLowerCase(),
          child: Text(
            widget.species[0].toUpperCase() + widget.species.substring(1),
          ),
        ),
      ];
    }
  }

  List<DataRow> _buildDataRows() {
    final speciesRanges = _normalRanges[_selectedSpecies]!;

    return [
      DataRow(cells: [
        DataCell(Text('Blood Urea Nitrogen (BUN) (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _bunController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'BUN is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['bun']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Creatinine (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _creatinineController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Creatinine is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['creatinine']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Phosphorus (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _phosphorusController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phosphorus is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['phosphorus']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Potassium (mEq/L)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _potassiumController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Potassium is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['potassium']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Sodium (mEq/L)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _sodiumController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sodium is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['sodium']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    ];
  }
}
