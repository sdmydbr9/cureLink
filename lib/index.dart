import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'medicine/view.dart';

void main() {
  runApp(MedicalPortalApp());
}

class MedicalPortalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Portal',
      home: MedicalPortalHomePage(),
    );
  }
}

class MedicalPortalHomePage extends StatefulWidget {
  @override
  _MedicalPortalHomePageState createState() => _MedicalPortalHomePageState();
}

class _MedicalPortalHomePageState extends State<MedicalPortalHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMenu(BuildContext context) {
    final radius = Radius.circular(8.0);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50,
        kToolbarHeight,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'admin',
          child: Row(
            children: [
              Icon(CupertinoIcons.gear, size: 20),
              SizedBox(width: 10),
              Text('Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'terms',
          child: Row(
            children: [
              Icon(CupertinoIcons.doc_plaintext, size: 20),
              SizedBox(width: 10),
              Text('Terms & Conditions'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(CupertinoIcons.arrow_uturn_left, size: 20),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(radius),
      ),
    ).then((value) {
      if (value == 'admin') {
        // Navigate to the ViewScreen when 'Admin' is selected
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewScreen()),
        );
      } else if (value == 'terms') {
        // Add your logic here for the terms menu option
        // For example, _showTermsAndConditionsDialog(context);
      } else if (value == 'logout') {
        // Add your logic here for the logout menu option
        // For example, Navigator.pushNamed(context, '/logout');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var pill;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Portal'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MedicalPortalTab(
            title: 'Contribute Clinical Notes',
            icon: CupertinoIcons.book,
            onTap: () {
              Navigator.pushNamed(context, '/form');
            },
          ),
          MedicalPortalTab(
            title: 'Contribute Lab Results',
            icon: CupertinoIcons.lab_flask,
            onTap: () {
              Navigator.pushNamed(context, '/lab_report');
            },
          ),
          MedicalPortalTab(
            title: 'Contribute Medication',
            icon: CupertinoIcons.capsule,
            onTap: () {
              Navigator.pushNamed(context, '/dosage');
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 16.0), // Add spacing at the bottom
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
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book),
              label: 'Clinical Notes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.lab_flask),
              label: 'Lab Results',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.capsule),
              label: 'Medication',
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalPortalTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;

  MedicalPortalTab({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: CupertinoColors.black,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
