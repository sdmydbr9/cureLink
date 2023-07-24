import 'package:flutter/material.dart';
import 'package:cure_link/tests/process_lft.dart';

class LftPage extends StatefulWidget {
  final String opdNumber;
  final String species;

  LftPage({required this.opdNumber, required this.species});

  @override
  _LftPageState createState() => _LftPageState();
}

class _LftPageState extends State<LftPage> {
  String? _selectedSpecies;

  final TextEditingController _opdNumberController = TextEditingController();
  final TextEditingController _totalBilirubinController =
      TextEditingController();
  final TextEditingController _directBilirubinController =
      TextEditingController();
  final TextEditingController _indirectBilirubinController =
      TextEditingController();
  final TextEditingController _astController = TextEditingController();
  final TextEditingController _altController = TextEditingController();
  final TextEditingController _alkalinePhosphataseController =
      TextEditingController();
  final TextEditingController _totalProteinController = TextEditingController();
  final TextEditingController _albuminController = TextEditingController();
  final TextEditingController _globulinController = TextEditingController();
  final TextEditingController _agRatioController = TextEditingController();

  final Map<String, Map<String, String>> _normalRanges = {
    'canine': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'equine': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'bovine': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'porcine': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'avian': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'caprine': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
    'feline': {
      'totalBilirubin': '0.1-0.4',
      'directBilirubin': '0-0.2',
      'indirectBilirubin': '0.1-0.4',
      'ast': '15-45',
      'alt': '10-101',
      'alkalinePhosphatase': '5-131',
      'totalProtein': '5-7.5',
      'albumin': '2.7-4.2',
      'globulin': '1.6-3.6',
      'agRatio': '1-2',
    },
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _opdNumberController.dispose();
    _totalBilirubinController.dispose();
    _directBilirubinController.dispose();
    _indirectBilirubinController.dispose();
    _astController.dispose();
    _altController.dispose();
    _alkalinePhosphataseController.dispose();
    _totalProteinController.dispose();
    _albuminController.dispose();
    _globulinController.dispose();
    _agRatioController.dispose();
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
              'Veterinary Liver Function Test',
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
                        DataColumn(label: Text('Liver Parameter')),
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
                        final totalBilirubinValue =
                            _totalBilirubinController.text.trim();
                        final directBilirubinValue =
                            _directBilirubinController.text.trim();
                        final indirectBilirubinValue =
                            _indirectBilirubinController.text.trim();
                        final astValue = _astController.text.trim();
                        final altValue = _altController.text.trim();
                        final alkalinePhosphataseValue =
                            _alkalinePhosphataseController.text.trim();
                        final totalProteinValue =
                            _totalProteinController.text.trim();
                        final albuminValue = _albuminController.text.trim();
                        final globulinValue = _globulinController.text.trim();
                        final agRatioValue = _agRatioController.text.trim();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessLftPage(
                              opdNumber: _opdNumberController.text.trim(),
                              species: _selectedSpecies!,
                              totalBilirubin: totalBilirubinValue,
                              directBilirubin: directBilirubinValue,
                              indirectBilirubin: indirectBilirubinValue,
                              ast: astValue,
                              alt: altValue,
                              alkalinePhosphatase: alkalinePhosphataseValue,
                              totalProtein: totalProteinValue,
                              albumin: albuminValue,
                              globulin: globulinValue,
                              agRatio: agRatioValue,
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
        DataCell(Text('Total Bilirubin (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _totalBilirubinController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Total Bilirubin is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['totalBilirubin']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Direct Bilirubin (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _directBilirubinController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Direct Bilirubin is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['directBilirubin']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Indirect Bilirubin (mg/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _indirectBilirubinController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Indirect Bilirubin is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['indirectBilirubin']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('AST (U/L)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _astController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'AST is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['ast']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('ALT (U/L)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _altController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'ALT is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['alt']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Alkaline Phosphatase (U/L)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _alkalinePhosphataseController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alkaline Phosphatase is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['alkalinePhosphatase']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Total Protein (g/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _totalProteinController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Total Protein is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['totalProtein']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Albumin (g/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _albuminController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Albumin is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['albumin']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('Globulin (g/dL)')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _globulinController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Globulin is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['globulin']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      DataRow(cells: [
        DataCell(Text('A/G Ratio')),
        DataCell(TextFormField(
          keyboardType: TextInputType.number,
          controller: _agRatioController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'A/G Ratio is required';
            }
            return null;
          },
        )),
        DataCell(
          Text(
            speciesRanges['agRatio']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    ];
  }
}
