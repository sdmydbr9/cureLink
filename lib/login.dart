import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authentication/authentication.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool)
      setAuthenticated; // Callback function to update authentication status
  final Authentication authentication; // Instance of the Authentication class

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
                title: Text('Error'),
                content: Text('Failed to fetch username. Please try again.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
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
                title: Text('Verification Failed'),
                content: Text('OTP verification failed. Please try again.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
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
            title: Text('Login Failed'),
            content: Text('Invalid username or password'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
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

  Widget _buildVerificationDialog(BuildContext context, String username) {
    final TextEditingController otpController = TextEditingController();

    return AlertDialog(
      title: Text('OTP Verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter the OTP received on your device:'),
          SizedBox(height: 8.0),
          TextField(
            controller: otpController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'OTP',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Verify'),
          onPressed: () async {
            String otp = otpController.text;
            bool verificationResult =
                await widget.authentication.verifyOtp(username, otp);

            Navigator.of(context).pop(verificationResult);
          },
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

  @override
  Widget build(BuildContext context) {
    // Get the screen size and orientation
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Determine the layout and font size based on the screen size and orientation
    final layoutSpacing = isPortrait ? 16.0 : 32.0;
    final fontSize = isPortrait ? 16.0 : 20.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(layoutSpacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoTextField(
                  controller: usernameEmailController,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  placeholder: 'Username or Email',
                  prefix: Icon(CupertinoIcons.person),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: layoutSpacing),
                CupertinoTextField(
                  controller: passwordController,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  placeholder: 'Password',
                  obscureText: true,
                  prefix: Icon(CupertinoIcons.lock),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: layoutSpacing * 2),
                CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  onPressed: isLoading ? null : () => _handleLogin(context),
                  child: isLoading
                      ? CupertinoActivityIndicator()
                      : Text('Login',
                          style: TextStyle(
                              fontSize: fontSize,
                              color: CupertinoColors.white)),
                ),
                SizedBox(height: layoutSpacing),
                CupertinoButton(
                  onPressed: () => _navigateToSignup(context),
                  child: Text('Sign Up',
                      style: TextStyle(
                          fontSize: fontSize,
                          color: CupertinoColors.systemBlue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
