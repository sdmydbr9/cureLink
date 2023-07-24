import 'package:flutter/material.dart';

class ProcessDosageScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dosageList;
  final List<Map<String, dynamic>> medicationList;

  ProcessDosageScreen({required this.dosageList, required this.medicationList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processed Dosage'),
      ),
      body: SingleChildScrollView(
        // Wrap in a SingleChildScrollView with scrollDirection set to Axis.horizontal
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          // Wrap in another SingleChildScrollView with scrollDirection set to Axis.vertical
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dosage List:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Species')),
                    DataColumn(label: Text('Dosage')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Body Weight')),
                    DataColumn(label: Text('Weight Unit')),
                    DataColumn(label: Text('Route of Administration')),
                  ],
                  rows: dosageList.map((dosage) {
                    return DataRow(cells: [
                      DataCell(Text(dosage['species'] ?? '')),
                      DataCell(Text(dosage['dosage'] ?? '')),
                      DataCell(Text(dosage['unit'] ?? '')),
                      DataCell(Text(dosage['bodyWeight'] ?? '')),
                      DataCell(Text(dosage['weightUnit'] ?? '')),
                      DataCell(Text(dosage['route'] ?? '')),
                    ]);
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Medication List:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Concentration')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Presentation')),
                    DataColumn(label: Text('Unit')),
                    DataColumn(label: Text('Reconstitution')),
                    DataColumn(label: Text('Image')),
                  ],
                  rows: medicationList.map((medication) {
                    return DataRow(cells: [
                      DataCell(Text(medication['type'] ?? '')),
                      DataCell(Text(medication['name'] ?? '')),
                      DataCell(Text(medication['concentration'] ?? '')),
                      DataCell(Text(medication['unit'] ?? '')),
                      DataCell(Text(medication['presentation'] ?? '')),
                      DataCell(Text(medication['presentationUnit'] ?? '')),
                      DataCell(Text(medication['reconstitutionValue'] != null
                          ? '${medication['reconstitutionValue']} ${medication['reconstitutionUnit']}'
                          : 'N/A')),
                      DataCell(medication['image'] != null
                          ? Image.memory(medication['image'])
                          : Text('No Image')),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
