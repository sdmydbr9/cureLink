import 'package:flutter/material.dart';

class ProcessCbcPage extends StatelessWidget {
  final String opdNumber;
  final String species;
  final String totalWbcCount;
  final String granulocyte;
  final String lymphocyte;
  final String monocyte;
  final String totalRbc;
  final String hemoglobin;
  final String pcv;
  final String mcv;
  final String mch;
  final String mchc;
  final String plateletCount;

  ProcessCbcPage({
    required this.opdNumber,
    required this.species,
    required this.totalWbcCount,
    required this.granulocyte,
    required this.lymphocyte,
    required this.monocyte,
    required this.totalRbc,
    required this.hemoglobin,
    required this.pcv,
    required this.mcv,
    required this.mch,
    required this.mchc,
    required this.plateletCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process CBC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              'Total WBC Count: $totalWbcCount x 10³/μL',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Granulocyte: $granulocyte%',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Lymphocyte: $lymphocyte%',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Monocyte: $monocyte%',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total RBC: $totalRbc x 10⁶/μL',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Hemoglobin: $hemoglobin g/dL',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'PCV: $pcv%',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'MCV: $mcv fl',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'MCH: $mch pg',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'MCHC: $mchc g/dL',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Platelet Count: $plateletCount x 10³/μL',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
