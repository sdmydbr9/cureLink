import 'package:flutter/material.dart';
import 'package:cure_link/tests/process_cbc.dart';

class CbcPage extends StatefulWidget {
  final String opdNumber;
  final String species;

  CbcPage({required this.opdNumber, required this.species});

  @override
  _CbcPageState createState() => _CbcPageState();
}

class _CbcPageState extends State<CbcPage> {
  String? _selectedSpecies;

  final TextEditingController _opdNumberController = TextEditingController();
  final TextEditingController _totalWbcCountController =
      TextEditingController();
  final TextEditingController _granulocyteController = TextEditingController();
  final TextEditingController _lymphocyteController = TextEditingController();
  final TextEditingController _monocyteController = TextEditingController();
  final TextEditingController _totalRbcController = TextEditingController();
  final TextEditingController _hemoglobinController = TextEditingController();
  final TextEditingController _pcvController = TextEditingController();
  final TextEditingController _mcvController = TextEditingController();
  final TextEditingController _mchController = TextEditingController();
  final TextEditingController _mchcController = TextEditingController();
  final TextEditingController _plateletCountController =
      TextEditingController();

  final Map<String, Map<String, String>> _normalRanges = {
    'canine': {
      'total_wbc_count': '5-17 x 10³/μL',
      'granulocyte': '60-77%',
      'lymphocyte': '12-30%',
      'monocyte': '2-9%',
      'total_rbc': '5.5-8.5 x 10⁶/μL',
      'hemoglobin': '12-18 g/dL',
      'pcv': '37-55%',
      'mcv': '60-77 fl',
      'mch': '19-26 pg',
      'mchc': '32-36 g/dL',
      'platelet_count': '150-400 x 10³/μL',
    },
    'feline': {
      'total_wbc_count': '5-19 x 10³/μL',
      'granulocyte': '35-75%',
      'lymphocyte': '20-55%',
      'monocyte': '0-8%',
      'total_rbc': '6.5-11.5 x 10⁶/μL',
      'hemoglobin': '9-15 g/dL',
      'pcv': '28-45%',
      'mcv': '39-55 fl',
      'mch': '11-17 pg',
      'mchc': '31-37 g/dL',
      'platelet_count': '200-500 x 10³/μL',
    },
    'equine': {
      'total_wbc_count': '6-12 x 10³/μL',
      'granulocyte': '40-60%',
      'lymphocyte': '30-45%',
      'monocyte': '0-4%',
      'total_rbc': '5-10 x 10⁶/μL',
      'hemoglobin': '11-16 g/dL',
      'pcv': '32-48%',
      'mcv': '45-59 fl',
      'mch': '15-22 pg',
      'mchc': '31-37 g/dL',
      'platelet_count': '100-300 x 10³/μL',
    },
    'bovine': {
      'total_wbc_count': '5-12 x 10³/μL',
      'granulocyte': '30-50%',
      'lymphocyte': '40-60%',
      'monocyte': '2-10%',
      'total_rbc': '5.5-10.5 x 10⁶/μL',
      'hemoglobin': '10-15 g/dL',
      'pcv': '24-36%',
      'mcv': '28-38 fl',
      'mch': '10-15 pg',
      'mchc': '32-36 g/dL',
      'platelet_count': '150-400 x 10³/μL',
    },
    'porcine': {
      'total_wbc_count': '10-22 x 10³/μL',
      'granulocyte': '50-75%',
      'lymphocyte': '10-40%',
      'monocyte': '5-15%',
      'total_rbc': '5-8 x 10⁶/μL',
      'hemoglobin': '11-15 g/dL',
      'pcv': '30-45%',
      'mcv': '55-75 fl',
      'mch': '16-24 pg',
      'mchc': '30-35 g/dL',
      'platelet_count': '200-600 x 10³/μL',
    },
    'avian': {
      'total_wbc_count': '12-25 x 10³/μL',
      'granulocyte': '30-50%',
      'lymphocyte': '40-60%',
      'monocyte': '0-10%',
      'total_rbc': '3-5.5 x 10⁶/μL',
      'hemoglobin': '9-14 g/dL',
      'pcv': '30-50%',
      'mcv': '150-250 fl',
      'mch': '15-25 pg',
      'mchc': '32-38 g/dL',
      'platelet_count': '50-400 x 10³/μL',
    },
    'caprine': {
      'total_wbc_count': '5-17 x 10³/μL',
      'granulocyte': '60-77%',
      'lymphocyte': '12-30%',
      'monocyte': '2-9%',
      'total_rbc': '7-12 x 10⁶/μL',
      'hemoglobin': '9-14 g/dL',
      'pcv': '28-45%',
      'mcv': '33-50 fl',
      'mch': '11-17 pg',
      'mchc': '32-38 g/dL',
      'platelet_count': '150-400 x 10³/μL',
    },
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _opdNumberController.dispose();
    _totalWbcCountController.dispose();
    _granulocyteController.dispose();
    _lymphocyteController.dispose();
    _monocyteController.dispose();
    _totalRbcController.dispose();
    _hemoglobinController.dispose();
    _pcvController.dispose();
    _mcvController.dispose();
    _mchController.dispose();
    _mchcController.dispose();
    _plateletCountController.dispose();
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
      appBar: AppBar(
        title: const Text('Veterinary CBC Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Veterinary CBC Test',
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
                        DataColumn(label: Text('CBC Parameter')),
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
                        final totalWbcCountValue =
                            _totalWbcCountController.text.trim();
                        final granulocyteValue =
                            _granulocyteController.text.trim();
                        final lymphocyteValue =
                            _lymphocyteController.text.trim();
                        final monocyteValue = _monocyteController.text.trim();
                        final totalRbcValue = _totalRbcController.text.trim();
                        final hemoglobinValue =
                            _hemoglobinController.text.trim();
                        final pcvValue = _pcvController.text.trim();
                        final mcvValue = _mcvController.text.trim();
                        final mchValue = _mchController.text.trim();
                        final mchcValue = _mchcController.text.trim();
                        final plateletCountValue =
                            _plateletCountController.text.trim();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProcessCbcPage(
                              opdNumber: _opdNumberController.text.trim(),
                              species: _selectedSpecies!,
                              totalWbcCount: totalWbcCountValue,
                              granulocyte: granulocyteValue,
                              lymphocyte: lymphocyteValue,
                              monocyte: monocyteValue,
                              totalRbc: totalRbcValue,
                              hemoglobin: hemoglobinValue,
                              pcv: pcvValue,
                              mcv: mcvValue,
                              mch: mchValue,
                              mchc: mchcValue,
                              plateletCount: plateletCountValue,
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
          value: 'bovine',
          child: Text('Bovine'),
        ),
        DropdownMenuItem<String>(
          value: 'equine',
          child: Text('equine'),
        ),
        DropdownMenuItem<String>(
          value: 'porcine',
          child: Text('Porcine'),
        ),
        DropdownMenuItem<String>(
          value: 'caprine',
          child: Text('Caprine'),
        ),
        // Add other species' dropdown items
        // ...
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
    if (_selectedSpecies == null) {
      return [];
    }

    final speciesRanges = _normalRanges[_selectedSpecies]!;

    return [
      DataRow(
        cells: [
          DataCell(Text('Total WBC Count')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _totalWbcCountController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Total WBC Count is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['total_wbc_count']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Granulocyte')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _granulocyteController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Granulocyte is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['granulocyte']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Lymphocyte')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _lymphocyteController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lymphocyte is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['lymphocyte']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Monocyte')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _monocyteController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Monocyte is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['monocyte']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Total RBC')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _totalRbcController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Total RBC is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['total_rbc']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Hemoglobin')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _hemoglobinController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Hemoglobin is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['hemoglobin']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('PCV')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _pcvController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PCV is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['pcv']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('MCV')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _mcvController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'MCV is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['mcv']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('MCH')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _mchController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'MCH is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['mch']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('MCHC')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _mchcController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'MCHC is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['mchc']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text('Platelet Count')),
          DataCell(TextFormField(
            keyboardType: TextInputType.number,
            controller: _plateletCountController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Platelet Count is required';
              }
              return null;
            },
          )),
          DataCell(
            Text(
              speciesRanges['platelet_count']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ];
  }
}
