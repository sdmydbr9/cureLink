import 'package:flutter/material.dart';
import 'tests/cbc.dart';
import 'tests/lft.dart';
import 'tests/hp.dart';
import 'tests/kft.dart';

class LabReportPage extends StatelessWidget {
  final String opdNumber;
  final String species;

  LabReportPage({required this.opdNumber, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Report Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OPD Number: $opdNumber',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'species: $species',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Test: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _navigateToTestPage(context, value);
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'KFT',
                        child: Text('KFT'),
                      ),
                      PopupMenuItem(
                        value: 'LFT',
                        child: Text('LFT'),
                      ),
                      PopupMenuItem(
                        value: 'CBC',
                        child: Text('CBC'),
                      ),
                      PopupMenuItem(
                        value: 'HP',
                        child: Text('HP'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTestPage(BuildContext context, String test) {
    Widget page;
    switch (test) {
      case 'KFT':
        page = KftPage(
          opdNumber: opdNumber,
          species: species,
        );
        break;
      case 'LFT':
        page = LftPage(
          opdNumber: opdNumber,
          species: species,
        );
        break;
      case 'CBC':
        page = CbcPage(
          opdNumber: opdNumber,
          species: species,
        );
        break;
      case 'HP':
        page = HemoprotozoaPage(
          opdNumber: opdNumber,
          species: species,
        );
        break;
      default:
        page = Container();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
