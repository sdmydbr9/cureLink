import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  Future<bool> login(
      BuildContext context, String usernameEmail, String password) async {
    if (isEmail(usernameEmail)) {
      return await loginWithEmail(context, usernameEmail, password);
    } else {
      return await loginWithCurl(context, usernameEmail, password);
    }
  }

  Future<bool> loginWithCurl(
      BuildContext context, String username, String password) async {
    final response = await _loginWithCurl(username, password);

    if (response == "Login successful") {
      print('Login with username: $username, password: $password - Successful');
      return true;
    } else {
      print('Login with username: $username, password: $password - Failed');
      return false;
    }
  }

  Future<String> _loginWithCurl(String username, String password) async {
    final url = 'https://pethealthwizard.tech:4488/login';
    final body = {'username': username, 'password': password};

    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['message'] == 'Login successful') {
        return 'Login successful';
      } else {
        return 'Login failed';
      }
    } else {
      return 'Login failed';
    }
  }

  Future<bool> loginWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Login with email: $email, password: $password - Successful');
      return true;
    } catch (error) {
      print('Login with email: $email, password: $password - Failed');
      return false;
    }
  }

  Future<String> getUsernameByEmail(String email) async {
    final response = await http.get(Uri.parse(
      'https://pethealthwizard.tech:4488/get_username_by_email/$email',
    ));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['username'];
    } else {
      throw Exception('Failed to fetch username');
    }
  }

  Future<bool> checkTwoFaStatus(String usernameEmail) async {
    String username = usernameEmail;
    if (isEmail(usernameEmail)) {
      try {
        username = await getUsernameByEmail(usernameEmail);
      } catch (error) {
        return false;
      }
    }

    final response = await http.get(
      Uri.parse('https://pethealthwizard.tech:4488/2FA_status/$username'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['2FA_status'];
    } else {
      return false;
    }
  }

  Future<bool> verifyOtp(String username, String otp) async {
    final url = 'https://pethealthwizard.tech:4488/verify';
    final body = {'username': username, 'otp': otp};

    final response = await http.post(Uri.parse(url), body: body);

    if (response.statusCode == 200) {
      final responseBody = response.body;
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool isEmail(String input) {
    final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return regex.hasMatch(input);
  }
}
