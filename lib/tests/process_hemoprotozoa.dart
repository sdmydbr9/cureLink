import 'package:flutter/material.dart';
import 'package:cure_link/tests/hp.dart';

class ProcessHemoprotozoaPage extends StatelessWidget {
  final String opdNumber;
  final String? species;
  final List<DiseaseItem> selectedDiseases;
  final bool showOthers;
  final String? otherDisease;
  final String? otherResult;
  final String? otherRemarks;

  ProcessHemoprotozoaPage({
    required this.opdNumber,
    required this.species,
    required this.selectedDiseases,
    required this.showOthers,
    this.otherDisease,
    this.otherResult,
    this.otherRemarks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Process Hemoprotozoa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Process Hemoprotozoa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'OPD Number: $opdNumber',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Species: $species',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (selectedDiseases.isNotEmpty) ...[
              const Text(
                'Selected Diseases:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var diseaseItem in selectedDiseases) ...[
                ListTile(
                  title: Text(diseaseItem.disease),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Result: ${diseaseItem.result ?? 'Not selected'}'),
                      if (diseaseItem.remarks != null)
                        Text('Remarks: ${diseaseItem.remarks}'),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ],
            if (showOthers && otherDisease != null && otherResult != null) ...[
              const Text(
                'Other Disease:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(otherDisease!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result: $otherResult'),
                    if (otherRemarks != null) Text('Remarks: $otherRemarks'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
