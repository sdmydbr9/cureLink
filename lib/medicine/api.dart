import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicationAPI {
  static Future<bool> checkNameAvailability(String name) async {
    final url = Uri.parse('https://www.pethealthwizard.tech:8844/?name=$name');
    final endpoint = '/?name=$name';

    try {
      print('Making API request to endpoint: $endpoint');
      print('URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('JSON Response: $jsonResponse');

        if (jsonResponse['result'] == 'exists') {
          return true;
        } else if (jsonResponse['result'] == 'not_exists') {
          return false;
        }
      } else {
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making API request: $e');
    }

    return false;
  }
}
