import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tests/cbc.dart';
import 'tests/lft.dart';
import 'tests/hp.dart';
import 'tests/kft.dart';

class LabReportPage extends StatefulWidget {
  final String opdNumber;
  final String species;

  LabReportPage({required this.opdNumber, required this.species});

  @override
  _LabReportPageState createState() => _LabReportPageState();
}

class _LabReportPageState extends State<LabReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Report Page'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OPD Number: ${widget.opdNumber}',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'Species: ${widget.species}',
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
          KftPage(opdNumber: widget.opdNumber, species: widget.species),
          LftPage(opdNumber: widget.opdNumber, species: widget.species),
          CbcPage(opdNumber: widget.opdNumber, species: widget.species),
          HemoprotozoaPage(
              opdNumber: widget.opdNumber, species: widget.species),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CupertinoTabBar(
          backgroundColor: CupertinoColors.extraLightBackgroundGray,
          activeColor: Color.fromARGB(255, 0, 64, 221),
          currentIndex: _tabController.index,
          onTap: (index) {
            setState(() {
              _tabController.index = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'KFT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'LFT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'CBC',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'HP',
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
          opdNumber: widget.opdNumber,
          species: widget.species,
        );
        break;
      case 'LFT':
        page = LftPage(
          opdNumber: widget.opdNumber,
          species: widget.species,
        );
        break;
      case 'CBC':
        page = CbcPage(
          opdNumber: widget.opdNumber,
          species: widget.species,
        );
        break;
      case 'HP':
        page = HemoprotozoaPage(
          opdNumber: widget.opdNumber,
          species: widget.species,
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
