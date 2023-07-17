import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Portal',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        // Change the primary color to the iOS blue accent
        colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: CupertinoColors
                .systemGrey), // Use iOS blue as the secondary color
        fontFamily: 'Arial',
      ),
      // Use '/' as the home route, it will redirect to LoginScreen if not authenticated
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
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: Text('Not Found'),
                ),
                body: Center(
                  child: Text('Page not found'),
                ),
              ),
            );
        }
      },
    );
  }
}
