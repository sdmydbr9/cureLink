import 'package:flutter/material.dart';
import 'package:cure_link/tests/process_hemoprotozoa.dart';

class DiseaseItem {
  String disease;
  bool isChecked;
  String? result;
  String? remarks;
  bool showRemarks;

  DiseaseItem({
    required this.disease,
    this.isChecked = false,
    this.result,
    this.remarks,
    this.showRemarks = false,
  });
}

class HemoprotozoaPage extends StatefulWidget {
  final String opdNumber;
  final String? species;

  HemoprotozoaPage({required this.opdNumber, this.species});

  @override
  _HemoprotozoaPageState createState() => _HemoprotozoaPageState();
}

class _HemoprotozoaPageState extends State<HemoprotozoaPage> {
  Map<String, List<String>> speciesDiseases = {
    'canine': [
      'Canine Babesiosis',
      'Canine Ehrlichiosis',
      'Canine Hepatozoonosis',
      'Canine Hemotropic Mycoplasmosis',
      'Canine Leishmaniasis',
    ],
    'feline': [
      'Feline Hemotropic Mycoplasmosis',
      'Feline Leukemia Virus (FeLV)',
      'Feline Immunodeficiency Virus (FIV)',
      'Feline Infectious Peritonitis (FIP)',
      'Feline Hemobartonellosis',
    ],
    'equine': [
      'Equine Infectious Anemia (EIA)',
      'Equine Piroplasmosis',
      'Equine Babesiosis',
      'Equine Trypanosomiasis',
      'Equine Hemotropic Mycoplasmosis',
    ],
    'bovine': [
      'Bovine Anaplasmosis',
      'Bovine Babesiosis',
      'Bovine Tropical Theileriosis',
      'Bovine Hemotropic Mycoplasmosis',
      'Bovine Leukemia Virus (BLV)',
    ],
    'caprine': [
      'Caprine Anaplasmosis',
      'Caprine Babesiosis',
      'Caprine Hemotropic Mycoplasmosis',
      'Caprine Trypanosomiasis',
      'Caprine Theileriosis',
    ],
    // Add more species and their diseases here
  };

  List<DiseaseItem> selectedDiseases = [];
  String? _selectedSpecies;
  bool showOthers = false;
  String? otherDisease;
  String? otherResult;
  String? otherRemarks;

  @override
  void initState() {
    super.initState();
    if (widget.species != null) {
      _selectedSpecies = widget.species!.toLowerCase();
      if (speciesDiseases.containsKey(_selectedSpecies)) {
        selectedDiseases = speciesDiseases[_selectedSpecies]!
            .map((disease) => DiseaseItem(disease: disease))
            .toList();
      }
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
              'Hemoprotozoa Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'OPD Number: ${widget.opdNumber}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.species == null) ...[
              const Text('Species:', style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                items: _buildSpeciesDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value;
                    selectedDiseases =
                        speciesDiseases.containsKey(_selectedSpecies)
                            ? speciesDiseases[_selectedSpecies]!
                                .map((disease) => DiseaseItem(disease: disease))
                                .toList()
                            : [];
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
            if (widget.species != null) ...[
              Text(
                'Species: ${widget.species}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (selectedDiseases.isNotEmpty) ...[
                const Text('Diseases:', style: TextStyle(fontSize: 16)),
                for (var diseaseItem in selectedDiseases) ...[
                  ListTile(
                    title: Row(
                      children: [
                        Checkbox(
                          value: diseaseItem.isChecked,
                          onChanged: (value) {
                            setState(() {
                              diseaseItem.isChecked = value!;
                              if (!diseaseItem.isChecked) {
                                diseaseItem.result = null;
                                diseaseItem.showRemarks = false;
                              }
                            });
                          },
                        ),
                        Text(diseaseItem.disease),
                        if (diseaseItem.isChecked) ...[
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: diseaseItem.result,
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'Positive',
                                child: Text('Positive'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Negative',
                                child: Text('Negative'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                diseaseItem.result = value;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Remarks',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  diseaseItem.remarks = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
              ListTile(
                title: Row(
                  children: [
                    Checkbox(
                      value: showOthers,
                      onChanged: (value) {
                        setState(() {
                          showOthers = value!;
                          if (!showOthers) {
                            otherDisease = null;
                            otherResult = null;
                            otherRemarks = null;
                          }
                        });
                      },
                    ),
                    const Text('Others'),
                    if (showOthers) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Disease Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              otherDisease = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: otherResult,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Positive',
                            child: Text('Positive'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Negative',
                            child: Text('Negative'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            otherResult = value;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Remarks',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              otherRemarks = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSpeciesDropdownItems() {
    return speciesDiseases.entries
        .map<DropdownMenuItem<String>>((MapEntry entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(
          entry.key[0].toUpperCase() + entry.key.substring(1),
        ),
      );
    }).toList();
  }

  void _submitForm() {
    final List<DiseaseItem> selectedDiseasesList = [];
    for (var diseaseItem in selectedDiseases) {
      if (diseaseItem.isChecked) {
        selectedDiseasesList.add(diseaseItem);
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessHemoprotozoaPage(
          opdNumber: widget.opdNumber,
          species: _selectedSpecies,
          selectedDiseases: selectedDiseasesList,
          showOthers: showOthers,
          otherDisease: showOthers ? otherDisease : null,
          otherResult: showOthers ? otherResult : null,
          otherRemarks: showOthers ? otherRemarks : null,
        ),
      ),
    );
  }
}
