import 'package:http/http.dart' as http;
import 'dart:convert';

class Medication {
  final String name;
  final String species;
  final double bodyWeight;

  Medication({
    required this.name,
    required this.species,
    required this.bodyWeight,
  });
}

Future<List<Medication>> fetchMedications(String query) async {
  String url = 'https://www.pethealthwizard.tech:8081/api/medication';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final medications = data['medications'] ?? [];

    List<Medication> medicationList = medications
        .map<Medication>((medication) => Medication(
              name: medication['name'],
              species: '',
              bodyWeight: 0,
            ))
        .toList();

    return medicationList
        .where((medication) =>
            medication.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  } else {
    return [];
  }
}

Future<List<String>> fetchSpecies(String query, String medicationName) async {
  String url =
      'https://www.pethealthwizard.tech:8081/api/medication/$medicationName';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final dosage = data['dosage'][0] as List<dynamic>;
    final speciesList = dosage
        .map<String>((species) => species['species'].toString())
        .where(
            (species) => species.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return speciesList;
  } else {
    return [];
  }
}

Future<List<String>> fetchNames() async {
  try {
    final response = await http
        .get(Uri.parse('https://www.pethealthwizard.tech:8080/api/names'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<String> names = [];

      for (final jsonString in responseData) {
        final List<dynamic> data = jsonDecode(jsonString);
        for (final item in data) {
          final Map<String, dynamic> nameData = item;
          final String name = nameData['name'] as String;
          names.add(name);
        }
      }

      return names;
    } else {
      print('Failed to fetch names: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> fetchNamesByType(String type) async {
  try {
    final response = await http.get(Uri.parse(
        'https://www.pethealthwizard.tech:8080/api/names-by-type/$type'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<Map<String, dynamic>> names = [];
      for (final item in data) {
        final Map<String, dynamic> nameData = item;
        names.add(nameData);
      }

      return names;
    } else {
      print('Failed to fetch names by type: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<List<String>> fetchTypes() async {
  try {
    final response = await http
        .get(Uri.parse('https://www.pethealthwizard.tech:8080/api/types'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final types = data.cast<String>();

      return types;
    } else {
      print('Failed to fetch types: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<dynamic> fetchMedicationDetailsByName(String name) async {
  String url =
      'https://www.pethealthwizard.tech:8080/api/medication-details/$name';
  print('API Request: $url'); // Log the API request to the console
  http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch medication details');
  }
}
