import 'package:flutter/material.dart';

class ProcessKftPage extends StatelessWidget {
  final String opdNumber;
  final String species;
  final String bun;
  final String creatinine;
  final String phosphorus;
  final String potassium;
  final String sodium;

  ProcessKftPage({
    required this.opdNumber,
    required this.species,
    required this.bun,
    required this.creatinine,
    required this.phosphorus,
    required this.potassium,
    required this.sodium,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KFT Result'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'KFT Result',
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
                DataColumn(label: Text('Kidney Parameter')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Blood Urea Nitrogen (BUN)')),
                  DataCell(
                    Row(
                      children: [
                        Text('$bun mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Creatinine')),
                  DataCell(
                    Row(
                      children: [
                        Text('$creatinine mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Phosphorus')),
                  DataCell(
                    Row(
                      children: [
                        Text('$phosphorus mg/dL'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Potassium')),
                  DataCell(
                    Row(
                      children: [
                        Text('$potassium mEq/L'),
                      ],
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sodium')),
                  DataCell(
                    Row(
                      children: [
                        Text('$sodium mEq/L'),
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
