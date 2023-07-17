import 'package:flutter/material.dart';

class ProcessLftPage extends StatelessWidget {
  final String opdNumber;
  final String species;
  final String totalBilirubin;
  final String directBilirubin;
  final String indirectBilirubin;
  final String ast;
  final String alt;
  final String alkalinePhosphatase;
  final String totalProtein;
  final String albumin;
  final String globulin;
  final String agRatio;

  ProcessLftPage({
    required this.opdNumber,
    required this.species,
    required this.totalBilirubin,
    required this.directBilirubin,
    required this.indirectBilirubin,
    required this.ast,
    required this.alt,
    required this.alkalinePhosphatase,
    required this.totalProtein,
    required this.albumin,
    required this.globulin,
    required this.agRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LFT Result'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'LFT Result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text('OPD Number: $opdNumber', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Species: $species', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Result:', style: TextStyle(fontSize: 16)),
            DataTable(
              columns: [
                DataColumn(label: Text('Liver Parameter')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Total Bilirubin')),
                  DataCell(
                    Row(
                      children: [
                        Text('$totalBilirubin mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Direct Bilirubin')),
                  DataCell(
                    Row(
                      children: [
                        Text('$directBilirubin mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Indirect Bilirubin')),
                  DataCell(
                    Row(
                      children: [
                        Text('$indirectBilirubin mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('AST')),
                  DataCell(
                    Row(
                      children: [
                        Text('$ast U/L'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('ALT')),
                  DataCell(
                    Row(
                      children: [
                        Text('$alt U/L'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Alkaline Phosphatase')),
                  DataCell(
                    Row(
                      children: [
                        Text('$alkalinePhosphatase U/L'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Total Protein')),
                  DataCell(
                    Row(
                      children: [
                        Text('$totalProtein g/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Albumin')),
                  DataCell(
                    Row(
                      children: [
                        Text('$albumin g/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Globulin')),
                  DataCell(
                    Row(
                      children: [
                        Text('$globulin g/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('A/G Ratio')),
                  DataCell(
                    Row(
                      children: [
                        Text(agRatio),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
