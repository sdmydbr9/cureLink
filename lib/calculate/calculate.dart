import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicationCalculator {
  static Future<Map<String, dynamic>> calculateMedication(
      String name, String species, double bodyWeight) async {
    // Make API request
    final apiUrl =
        'https://www.pethealthwizard.tech:8000/calculate-medication/$name/$species/$bodyWeight';
    final response = await http.get(Uri.parse(apiUrl));
    final data = jsonDecode(response.body);

    return data;
  }
}
