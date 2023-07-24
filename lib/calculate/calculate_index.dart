import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'trade_name.dart';
import 'anaesthesia.dart';
import 'calculate_screen.dart';
import 'package:flutter/cupertino.dart' as cupertino;

void main() {
  runApp(MedicationCalculatorApp());
}

class MedicationCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/calculator': (context) => CalculatorScreen(),
        '/tradeName': (context) => TradeNameWidget(),
        '/calculateAnesthesia': (context) => CalculateAnesthesiaPage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
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
              Icon(cupertino.CupertinoIcons.gear, size: 20),
              SizedBox(width: 10),
              Text('Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(cupertino.CupertinoIcons.info, size: 20),
              SizedBox(width: 10),
              Text('info'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(cupertino.CupertinoIcons.question_circle, size: 20),
              SizedBox(width: 10),
              Text('report a problem'),
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
        // Add your logic here for the admin menu option
        // For example, Navigator.pushNamed(context, '/admin_login');
      } else if (value == 'info') {
        //Navigator.pushNamed(context, '/calculator');
        // Add your logic here for the calculate option
      } else if (value == 'report') {
        // Add your logic here for the info option
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return cupertino.CupertinoPageScaffold(
      navigationBar: cupertino.CupertinoNavigationBar(
        middle: Text('Medication Calculator'),
        trailing: cupertino.CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.ellipsis,
            color: CupertinoColors.systemGrey, // Set the color to grey
          ),
          onPressed: () {
            _showMenu(context);
          },
        ),
      ),
      child: SafeArea(
        child: DefaultTextStyle(
          style: cupertino.CupertinoTheme.of(context).textTheme.textStyle,
          child: Padding(
            // Wrap CupertinoTabScaffold with Padding widget
            padding: EdgeInsets.only(
                bottom: 20.0), // Adjust the bottom padding as needed
            child: cupertino.CupertinoTabScaffold(
              tabBar: cupertino.CupertinoTabBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(cupertino.CupertinoIcons.function),
                    label: 'Calculate Medications',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(cupertino.CupertinoIcons.search),
                    label: 'Search by Trade Name',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(cupertino.CupertinoIcons.heart),
                    label: 'Calculate Anaesthesia',
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return CalculatorScreen();
                  case 1:
                    return TradeNameWidget();
                  case 2:
                    return CalculateAnesthesiaPage();
                  default:
                    return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
