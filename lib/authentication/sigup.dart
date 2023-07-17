import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'handle_signup.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController =
      TextEditingController(); // Added OTP controller
  bool isLoading = false;
  bool isUsernameAvailable = true;
  bool isEmailAvailable = true;
  bool isTwoFactorEnabled = false;
  String? secretCode;
  bool isOTPVerified = false;

  @override
  void initState() {
    super.initState();
    _setupTwoFactor();
  }

  void _setupTwoFactor() async {
    if (isTwoFactorEnabled) {
      secretCode = await SignupHandler.setupAuthenticator();
    } else {
      secretCode = null;
    }
    setState(() {});
  }

  void _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        isUsernameAvailable = true;
      });
      return;
    }

    if (username.isNotEmpty) {
      bool available = await SignupHandler.checkUsernameAvailability(username);
      setState(() {
        isUsernameAvailable = available;
      });

      if (!available) {
        _showCupertinoDialog(
            'Username Not Available', 'Please choose a different username.');
        usernameController.clear();
      }
    }
  }

  void _checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      setState(() {
        isEmailAvailable = true;
      });
      return;
    }

    if (email.isNotEmpty) {
      bool available = await SignupHandler.checkEmailAvailability(email);
      setState(() {
        isEmailAvailable = available;
      });

      if (!available) {
        _showCupertinoDialog(
            'Email Already Registered', 'Please use a different email.');
        emailController.clear();
      }
    }
  }

  void _showCupertinoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
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

  void _verifyOTP() {
    String otp = otpController.text;
    String secretCode = this.secretCode ?? '';

    bool otpVerified = SignupHandler.verifyOTP(otp, secretCode);

    if (otpVerified) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('OTP Verification'),
            content: const Text('OTP verification successful.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isOTPVerified = true;
                  });
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('OTP Verification'),
            content: const Text('Invalid OTP. Please enter a valid OTP.'),
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

  void _signupWithEmail() async {
    setState(() {
      isLoading = true;
    });

    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String otp = otpController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sign Up Failed'),
            content: const Text('Password and Confirm Password do not match.'),
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!isUsernameAvailable) {
      // Username is not available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sign Up Failed'),
            content: const Text('Please choose a different username.'),
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!isEmailAvailable) {
      // Email is already registered
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sign Up Failed'),
            content: const Text(
                'Email is already registered. Please use a different email.'),
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    bool signedUp = await SignupHandler.signUpWithEmail(
      username,
      email,
      password,
      secretCode,
      isTwoFactorEnabled,
    );

    setState(() {
      isLoading = false;
    });

    if (signedUp) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sign Up Successful'),
            content: const Text('You have successfully signed up!'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sign Up Failed'),
            content: const Text('Failed to sign up. Please try again.'),
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

  void _toggleTwoFactor(bool value) {
    setState(() {
      isTwoFactorEnabled = value;
      if (!isTwoFactorEnabled) {
        isOTPVerified = false;
      } else {
        _setupAuthenticator();
      }
    });
  }

  void _setupAuthenticator() async {
    secretCode = await SignupHandler.setupAuthenticator();
    setState(() {});
  }

  Widget buildVerifyOTPButton() {
    return Column(
      children: [
        CupertinoTextField(
          controller: otpController,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          placeholder: 'OTP',
          keyboardType: TextInputType.number,
          prefix: const Icon(CupertinoIcons.padlock),
        ),
        const SizedBox(height: 16.0),
        CupertinoButton(
          onPressed: isLoading ? null : _verifyOTP,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Verify OTP'),
        ),
      ],
    );
  }

  Widget buildSecretCodeWidget() {
    if (isTwoFactorEnabled && secretCode != null) {
      final otpUri = 'otpauth://totp/medical_portal?secret=$secretCode';
      return Column(
        children: [
          QrImage(
            data: otpUri,
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 16.0),
          Text('Secret Code: $secretCode'),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Sign Up'), // Set the title of the navigation bar
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DefaultTextStyle(
              style: CupertinoTheme.of(context)
                  .textTheme
                  .textStyle, // Use Cupertino text style
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CupertinoTextField(
                    controller: usernameController,
                    onChanged: _checkUsernameAvailability,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    placeholder: 'Username',
                    prefix: Icon(CupertinoIcons.person), // Use CupertinoIcons
                  ),
                  SizedBox(height: 16.0),
                  CupertinoTextField(
                    controller: emailController,
                    onChanged: _checkEmailAvailability,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    placeholder: 'Email',
                    prefix: Icon(CupertinoIcons.mail), // Use CupertinoIcons
                  ),
                  SizedBox(height: 16.0),
                  CupertinoTextField(
                    controller: passwordController,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    placeholder: 'Password',
                    obscureText: true,
                    prefix: Icon(CupertinoIcons.lock), // Use CupertinoIcons
                  ),
                  SizedBox(height: 16.0),
                  CupertinoTextField(
                    controller: confirmPasswordController,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    placeholder: 'Confirm Password',
                    obscureText: true,
                    prefix: Icon(CupertinoIcons.lock), // Use CupertinoIcons
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Enable 2FA'), // Cupertino text style applied
                      CupertinoSwitch(
                        value: isTwoFactorEnabled,
                        onChanged: _toggleTwoFactor,
                      ),
                    ],
                  ),
                  if (isTwoFactorEnabled) ...[
                    buildSecretCodeWidget(),
                    SizedBox(height: 16.0),
                    if (!isOTPVerified) buildVerifyOTPButton(),
                  ],
                  if ((!isTwoFactorEnabled || isOTPVerified) && !isLoading)
                    CupertinoButton(
                      onPressed: _signupWithEmail,
                      child: Text('Sign Up'),
                    ),
                  if (isLoading) SizedBox(height: 16.0),
                  if (isLoading) CupertinoActivityIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
