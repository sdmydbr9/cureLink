import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calculate/calculate_index.dart';
import 'calculate/calculate_screen.dart';
import 'lab_report.dart';
import 'form.dart';
import 'index.dart';
import 'custom.dart';
import 'medicine/dosage.dart';
import 'login.dart';
import 'authentication/authentication.dart';
import 'authentication/sigup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MedicalPortalApp());
}

class MedicalPortalApp extends StatefulWidget {
  @override
  _MedicalPortalAppState createState() => _MedicalPortalAppState();
}

class _MedicalPortalAppState extends State<MedicalPortalApp> {
  bool isAuthenticated = false;
  bool isLoading = true;

  void setAuthenticated(bool value) {
    setState(() {
      isAuthenticated = value;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set initial authentication state here (e.g., to false)
    isAuthenticated = false;

    initializeApp().then((_) {
      setState(() {
        isLoading = false; // Set isLoading to false when the content is ready
      });
    });
  }

  Future<void> initializeApp() async {
    // Add any additional app initialization code here
    // If you need to perform asynchronous tasks during initialization,
    // you can do it here and wait for the tasks to complete.
    await Future.delayed(
        Duration(seconds: 2)); // Simulate a 2-second delay for loading
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Portal',
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white, // Set the background color here
          body: Builder(
            builder: (BuildContext context) {
              if (isLoading) {
                // Show the Cupertino loading animation here
                return Center(child: CupertinoActivityIndicator());
              } else if (isAuthenticated) {
                return MedicalPortalHomePage();
              } else {
                return LoginScreen(
                  setAuthenticated: setAuthenticated,
                  authentication: Authentication(),
                );
              }
            },
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => isAuthenticated
                  ? MedicalPortalHomePage()
                  : LoginScreen(
                      setAuthenticated: setAuthenticated,
                      authentication: Authentication(),
                    ),
            );
          case '/home':
            if (isAuthenticated) {
              return MaterialPageRoute(
                builder: (_) => MedicalPortalHomePage(),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => LoginScreen(
                  setAuthenticated: setAuthenticated,
                  authentication: Authentication(),
                ),
              );
            }
          case '/form':
            return MaterialPageRoute(
              builder: (_) => isAuthenticated
                  ? MyForm()
                  : LoginScreen(
                      setAuthenticated: setAuthenticated,
                      authentication: Authentication(),
                    ),
            );
          case '/lab_report':
            return MaterialPageRoute(
              builder: (_) => isAuthenticated
                  ? LabReportPage(opdNumber: '', species: '')
                  : LoginScreen(
                      setAuthenticated: setAuthenticated,
                      authentication: Authentication(),
                    ),
            );
          case '/dosage':
            return MaterialPageRoute(
              builder: (_) => isAuthenticated
                  ? MedicationFormScreen()
                  : LoginScreen(
                      setAuthenticated: setAuthenticated,
                      authentication: Authentication(),
                    ),
            );
          case '/signup': // Define the '/signup' route
            return MaterialPageRoute(
              builder: (_) => SignupScreen(),
            );
          case '/calculatorScreen':
            return MaterialPageRoute(
              builder: (_) => MedicationCalculatorApp(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Not Found'),
                ),
                body: const Center(
                  child: Text('Page not found'),
                ),
              ),
            );
        }
      },
    );
  }
}
