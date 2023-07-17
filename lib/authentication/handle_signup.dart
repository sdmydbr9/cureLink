import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

class SignupHandler {
  static const String secretKeyKey = 'secret_key';

  static Future<bool> signUpWithEmail(
    String username,
    String email,
    String password,
    String? secretCode,
    bool isTwoFactorEnabled,
  ) async {
    try {
      // Check for duplicate username
      bool isUsernameAvailable = await checkUsernameAvailability(username);
      if (!isUsernameAvailable) {
        // Username is already taken
        return false;
      }

      // Check for duplicate email
      bool isEmailAvailable = await checkEmailAvailability(email);
      if (!isEmailAvailable) {
        // Email is already registered
        return false;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Save user data to the database
        bool isSuccess = await saveUserDataToDatabase(
          username,
          email,
          password,
          secretCode,
          isTwoFactorEnabled,
        );
        if (isSuccess) {
          // Successful signup
          return true;
        } else {
          // Failed to save user data to the database
          return false;
        }
      } else {
        // Failed signup
        return false;
      }
    } catch (e) {
      // Failed signup (error)
      return false;
    }
  }

  static Future<bool> signUpWithGoogle(bool isTwoFactorEnabled) async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        // Obtain the auth details from the Google sign-in
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        // Create a new credential using the obtained auth details
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase using the Google credential
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          String? secretCode;
          if (isTwoFactorEnabled) {
            secretCode = await setupAuthenticator();
          }

          // Save user data to the database
          bool isSuccess = await saveUserDataToDatabase(
            userCredential.user!.displayName ?? '',
            userCredential.user!.email ?? '',
            '',
            secretCode,
            isTwoFactorEnabled,
          );
          if (isSuccess) {
            // Successful signup with Google
            return true;
          } else {
            // Failed to save user data to the database
            return false;
          }
        }
      }

      // Failed signup with Google
      return false;
    } catch (e) {
      // Failed signup (error)
      return false;
    }
  }

  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final apiUrl =
          'https://pethealthwizard.tech:4488/check_username/$username';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        // Check if the username is available or already taken
        if (message == 'Username is available') {
          return true; // Username is available
        } else {
          return false; // Username is taken
        }
      } else {
        // Failed to check username availability
        return false;
      }
    } catch (e) {
      // Error occurred while checking username availability
      return false;
    }
  }

  static Future<bool> checkEmailAvailability(String email) async {
    try {
      final apiUrl = 'https://pethealthwizard.tech:4488/check_email/$email';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        // Check if the email is available or already registered
        if (message == 'Email is available') {
          return true; // Email is available
        } else {
          return false; // Email is registered
        }
      } else {
        // Failed to check email availability
        return false;
      }
    } catch (e) {
      // Error occurred while checking email availability
      return false;
    }
  }

  static Future<bool> saveUserDataToDatabase(
    String username,
    String email,
    String password,
    String? secretCode,
    bool isTwoFactorEnabled,
  ) async {
    try {
      final apiUrl = 'https://pethealthwizard.tech:4488/signup';
      final requestUrl = Uri.parse(apiUrl);
      final requestBody = {
        'email': email,
        'username': username,
        'password': password,
        '2FA': isTwoFactorEnabled.toString(),
        'secret_code': secretCode ?? '',
      };

      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      final requestBodyEncoded = _formatRequestData(requestBody);

      final curlCommand =
          'curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "$requestBodyEncoded" $apiUrl';
      print('API Request:');
      print(curlCommand);

      final response = await http.post(
        requestUrl,
        headers: headers,
        body: requestBodyEncoded,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        // Check if the user data was saved successfully
        if (message == 'Signup successful') {
          return true; // User data saved successfully
        } else {
          return false; // Failed to save user data
        }
      } else {
        // Failed to save user data to the database
        return false;
      }
    } catch (e) {
      // Error occurred while saving user data
      return false;
    }
  }

  static String _formatRequestData(Map<String, dynamic> data) {
    return data.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }

  static Future<String?> setupAuthenticator() async {
    try {
      final secretKey = OTP.randomSecret(); // Generate a new random secret key

      // Save the secret key to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(secretKeyKey, secretKey);

      print('Secret Key: $secretKey');

      // Return the secret key
      return secretKey;
    } catch (e) {
      // Handle any errors during the setup process
      print('Failed to set up authenticator: $e');
      return null;
    }
  }

  static String generateOTP(String secretKey) {
    try {
      // Get the current time in the Kolkata (Calcutta) time zone
      timezone.initializeTimeZones();
      final kolkataTimeZone = timezone.getLocation('Asia/Kolkata');
      final date = timezone.TZDateTime.now(kolkataTimeZone);

      // Generate the TOTP code using the secret key and current time
      String otp = OTP.generateTOTPCodeString(
        secretKey,
        date.millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      // Log the OTP generation
      print('Generated OTP: $otp');

      return otp;
    } catch (e) {
      print('Failed to generate OTP: $e');
      return '';
    }
  }

  static bool verifyOTP(String otp, String secretKey) {
    try {
      // Get the current time in the Kolkata (Calcutta) time zone
      timezone.initializeTimeZones();
      final kolkataTimeZone = timezone.getLocation('Asia/Kolkata');
      final date = timezone.TZDateTime.now(kolkataTimeZone);

      // Generate the TOTP code using the secret key and current time
      String currentTOTP = OTP.generateTOTPCodeString(
        secretKey,
        date.millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      // Log the verification process
      print('Verifying $secretKey with $otp');

      // Compare the generated TOTP code with the user-provided OTP
      bool otpVerified = otp == currentTOTP;

      // Log the verification result
      print('OTP verification result: $otpVerified');

      return otpVerified;
    } catch (e) {
      print('Failed to verify OTP: $e');
      return false;
    }
  }
}
