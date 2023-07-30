import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'authentication/authentication.dart';
import 'animation.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool) setAuthenticated;
  final Authentication authentication;

  LoginScreen({
    required this.setAuthenticated,
    required this.authentication,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    String usernameEmail = usernameEmailController.text;
    String password = passwordController.text;

    bool loggedIn =
        await widget.authentication.login(context, usernameEmail, password);

    setState(() {
      isLoading = false;
    });

    if (loggedIn) {
      String username = usernameEmail;
      if (widget.authentication.isEmail(usernameEmail)) {
        try {
          username =
              await widget.authentication.getUsernameByEmail(usernameEmail);
        } catch (error) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Error'),
                content:
                    const Text('Failed to fetch username. Please try again.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      }

      bool twoFaStatus = await widget.authentication.checkTwoFaStatus(username);

      if (!twoFaStatus) {
        widget.setAuthenticated(true);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        bool verificationResult = await showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildVerificationDialog(context, username),
        );

        if (verificationResult) {
          widget.setAuthenticated(true);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Verification Failed'),
                content:
                    const Text('OTP verification failed. Please try again.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showMenu(BuildContext context) {
    final radius = const Radius.circular(8.0);
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
              const Icon(CupertinoIcons.gear, size: 20),
              const SizedBox(width: 10),
              const Text('Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'calculate',
          child: Row(
            children: [
              const Icon(CupertinoIcons.doc_checkmark, size: 20),
              const SizedBox(width: 10),
              const Text('calculate'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              const Icon(CupertinoIcons.info, size: 20),
              const SizedBox(width: 10),
              const Text('know more'),
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
      } else if (value == 'calculate') {
        Navigator.pushNamed(context, '/calculatorScreen');
        // Add your logic here for the calculate
      } else if (value == 'info') {
        // Add your logic here for the info option
      }
    });
  }

  Widget _buildVerificationDialog(BuildContext context, String username) {
    final TextEditingController otpController = TextEditingController();

    return CupertinoAlertDialog(
      title: const Text('OTP Verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the OTP received on your device:'),
          const SizedBox(height: 8.0),
          CupertinoTextField(
            controller: otpController,
            textAlign: TextAlign.center, // Align the entered OTP at the center.
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            placeholder: 'OTP',
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child: CupertinoButton(
            child: const Text('Verify'),
            onPressed: () async {
              String otp = otpController.text;
              bool verificationResult =
                  await widget.authentication.verifyOtp(username, otp);

              Navigator.of(context).pop(verificationResult);
            },
          ),
        ),
      ],
    );
  }

  void _handleLogin(BuildContext context) {
    _login(context);
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  Future<void> _checkAvailability(String input, {bool isEmail = false}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String apiUrl;
      if (isEmail) {
        apiUrl =
            'https://pethealthwizard.tech:4488/check_email/${Uri.encodeComponent(input)}';
      } else {
        apiUrl =
            'https://pethealthwizard.tech:4488/check_username/${Uri.encodeComponent(input)}';
      }

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        if (isEmail) {
          if (message == 'Email is available') {
            showPassword = false; // Email is available, prompt user to sign up
            _showSignupPrompt();
          } else {
            showPassword = true; // Email is taken, show password field
          }
        } else {
          if (message == 'Username is available') {
            showPassword =
                false; // Username is available, prompt user to sign up
            _showSignupPrompt();
          } else {
            showPassword = true; // Username is taken, show password field
          }
        }
      } else {
        // Failed to check availability
        showPassword = false;
      }
    } catch (e) {
      // Error occurred while checking availability
      showPassword = false;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _checkEmailAvailability(String email) async {
    await _checkAvailability(email, isEmail: true);
  }

  void _handleArrowTap(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    String usernameEmail = usernameEmailController.text;

    if (widget.authentication.isEmail(usernameEmail)) {
      _checkEmailAvailability(usernameEmail);
    } else {
      _checkAvailability(usernameEmail);
    }
  }

  void _showSignupPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Signup First'),
          content: const Text(
              'The username/email does not exist. Please sign up first.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final layoutSpacing = isPortrait ? 16.0 : 32.0;
    final fontSize = isPortrait ? 16.0 : 20.0;

    final isDarkMode = false; // Always use the light theme

    final navBarHeight = const CupertinoNavigationBar().preferredSize.height;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        leading: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Image.asset('assets/icon.png', height: navBarHeight),
              onPressed: () {
                // Add any functionality for the icon button if needed
              },
            ),
            GestureDetector(
              // Wrap the Text widget with GestureDetector
              onTap: () {
                // Handle any onTap functionality if needed
              },
              child: const Text(
                'cureLink',
                style: TextStyle(
                  fontSize: 28.0,
                  color:
                      CupertinoColors.black, // Set the color of the text here
                ),
              ),
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.ellipsis,
            color: CupertinoColors.systemGrey, // Set the color to grey
          ),
          onPressed: () => _showMenu(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: CupertinoColors.white,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(layoutSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 40,
                    ),
                    LogoAnimation(),
                    SizedBox(height: layoutSpacing),
                    const SizedBox(
                      height: 40,
                    ),
                    CupertinoTextField(
                      controller: usernameEmailController,
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      placeholder: 'Username or Email',
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors
                            .placeholderText, // Set the color of the placeholder based on the theme
                      ),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Icon(CupertinoIcons.person),
                      ),
                      suffix: isLoading
                          ? const CupertinoActivityIndicator()
                          : CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: isLoading
                                  ? null
                                  : () => _handleArrowTap(context),
                              child: const Icon(
                                CupertinoIcons.arrow_right_circle,
                                color: CupertinoColors
                                    .black, // Change the color here
                              ),
                            ),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: CupertinoColors
                            .black, // Set the text color based on the theme
                      ),
                    ),
                    if (showPassword) ...[
                      SizedBox(height: layoutSpacing),
                      CupertinoTextField(
                        controller: passwordController,
                        decoration: BoxDecoration(
                          border: Border.all(color: CupertinoColors.systemGrey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        placeholder: 'Password',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors
                              .placeholderText, // Set the color of the placeholder based on the theme
                        ),
                        obscureText: true,
                        prefix: const Icon(CupertinoIcons.lock),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: CupertinoColors
                              .black, // Set the text color based on the theme
                        ),
                      ),
                      SizedBox(height: layoutSpacing * 2),
                      CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        onPressed:
                            isLoading ? null : () => _handleLogin(context),
                        child: isLoading
                            ? const CupertinoActivityIndicator()
                            : Text('Login',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    color: CupertinoColors.white)),
                      ),
                    ] else ...[
                      SizedBox(height: layoutSpacing),
                      CupertinoButton(
                        onPressed: () => _navigateToSignup(context),
                        child: Text('Sign Up',
                            style: TextStyle(
                                fontSize: fontSize,
                                color: CupertinoColors.systemBlue)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
