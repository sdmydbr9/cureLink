import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicationDetailInfo {
  final String type;
  final String name;
  final String concentration;
  final String unit;
  final String presentation;
  final String presentationUnit;
  final Uint8List image;

  MedicationDetailInfo({
    required this.type,
    required this.name,
    required this.concentration,
    required this.unit,
    required this.presentation,
    required this.presentationUnit,
    required this.image,
  });
}

class ImageHandler extends StatefulWidget {
  final int medicationId;

  const ImageHandler({required this.medicationId});

  @override
  _ImageHandlerState createState() => _ImageHandlerState();
}

class _ImageHandlerState extends State<ImageHandler> {
  bool isLoading = true;
  List<MedicationDetailInfo> medicationDetailsList = [];
  int selectedMedicationIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchImageData();
  }

  Future<void> fetchImageData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.pethealthwizard.tech:9999/medication/${widget.medicationId}'));
      print('API Request URL: ${response.request!.url}');
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('medication_details') &&
            jsonData['medication_details'] != '') {
          final medicationDetailsString = jsonData['medication_details'];
          final medicationDetails =
              json.decode(medicationDetailsString) as List<dynamic>;
          if (medicationDetails.isNotEmpty) {
            setState(() {
              medicationDetailsList = medicationDetails.map((medication) {
                if (medication.containsKey('image') &&
                    medication['image'] != '') {
                  String base64Image = medication['image'];
                  return MedicationDetailInfo(
                    type: medication['type'],
                    name: medication['name'],
                    concentration: medication['concentration'],
                    unit: medication['unit'],
                    presentation: medication['presentation'],
                    presentationUnit: medication['presentationUnit'],
                    image: base64Decode(base64Image),
                  );
                } else {
                  return MedicationDetailInfo(
                    type: medication['type'],
                    name: medication['name'],
                    concentration: medication['concentration'],
                    unit: medication['unit'],
                    presentation: medication['presentation'],
                    presentationUnit: medication['presentationUnit'],
                    image: Uint8List(0),
                  );
                }
              }).toList();
              isLoading = false;
            });
            return;
          }
        }
      }

      // Image not found
      print('Image not found.');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildImageWidget() {
    if (medicationDetailsList.isNotEmpty) {
      final currentMedication = medicationDetailsList[selectedMedicationIndex];
      return Column(
        children: [
          if (currentMedication.image.isNotEmpty)
            GestureDetector(
              onTap: () {
                _showFullImageDialog(currentMedication.image);
              },
              child: Image.memory(currentMedication.image),
            ),
          if (currentMedication.image.isEmpty)
            Text('Image not found for ${currentMedication.name}.'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < medicationDetailsList.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMedicationIndex = i;
                    });
                  },
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == selectedMedicationIndex
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      return Text('No images found.');
    }
  }

  void _showFullImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageBytes.isNotEmpty)
                Image.memory(imageBytes)
              else
                Text('Image not found for this medication.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading ? CircularProgressIndicator() : _buildImageWidget(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
