import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MedicalPortalApp());
}

class MedicalPortalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Portal',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
        brightness: Brightness.light,
      ),
      home: MedicalPortalHomePage(),
    );
  }
}

class MedicalPortalHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(), // Add the SideMenu widget as the drawer
      appBar: AppBar(
        title: Text('Medical Portal'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: CupertinoColors.extraLightBackgroundGray,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'CureLink',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.extraLightBackgroundGray,
              ),
            ),
            MenuItem(
              title: 'Contribute Clinical Notes',
              route: '/form',
            ),
            MenuItem(
              title: 'Contribute Lab Results',
              route: '/lab_report',
            ),
            MenuItem(
              title: 'Contribute Medication',
              route: '/dosage',
            ),
            MenuItem(
              title: 'View Entered Clinical Notes',
              route: '/form',
            ),
            Divider(),
            ..._buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = [
      MenuItem(
        title: 'Term & condition',
        route: '/terms_and_conditions',
        smallerFont: true,
      ),
      MenuItem(
        title: 'Admin login',
        route: '/admin_login',
        smallerFont: true,
      ),
      MenuItem(
        title: 'Logout',
        route: '/logout',
        smallerFont: true,
      ),
    ];

    // Custom list of widgets with adjusted spacing between menu items
    final adjustedMenuItems = <Widget>[];
    for (var i = 0; i < menuItems.length; i++) {
      adjustedMenuItems.add(menuItems[i]);
      if (i < menuItems.length - 1) {
        adjustedMenuItems.add(SizedBox(
            height: 1)); // Custom vertical padding for spacing adjustment
      }
    }

    return adjustedMenuItems;
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final String route;
  final bool
      smallerFont; // New parameter to indicate if the font size should be smaller

  const MenuItem({
    required this.title,
    required this.route,
    this.smallerFont = false, // Default value for smallerFont is false
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: smallerFont
              ? 16
              : 18, // Use a smaller font size if smallerFont is true
        ),
      ),
      onTap: () {
        if (route == '/terms_and_conditions') {
          // Show the terms and conditions in a dialog pop-up
          _showTermsAndConditionsDialog(context);
        } else {
          // Navigate to other screens as needed
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  // Function to show the terms and conditions dialog pop-up
  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Terms & Conditions'),
          content: SingleChildScrollView(
            child: FutureBuilder(
              future: _loadTermsText(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data.toString(),
                      style: TextStyle(fontSize: 16),
                    );
                  } else {
                    return Text('Error loading terms and conditions.');
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to load the content of terms.txt from the assets
  Future<String> _loadTermsText() async {
    return await rootBundle.loadString('assets/terms.txt');
  }
}
