import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import 'mediationdetailscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: ViewScreen(),
    );
  }
}

class ViewScreen extends StatefulWidget {
  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<dynamic> medications = [];
  bool isLoading = true;
  String searchText = '';

  Future<void> fetchMedications() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.pethealthwizard.tech:9999/medication'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          medications = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load medication data');
      }
    } catch (e) {
      throw Exception('Failed to load medication data');
    }
  }

  Widget _cupertinoLoadingWidget() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _decodeImage(String imageUrl, Map<String, dynamic> details) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImageDialog(details);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageSize = 100.0; // Adjust the size for the image
          final squareImageSize = imageSize * 0.75; // Use any ratio you prefer

          return Container(
            width: squareImageSize, // Make the container width square
            height: squareImageSize, // Make the container height square
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width:
                    squareImageSize, // Ensure the image fits the square container
                height:
                    squareImageSize, // Ensure the image fits the square container
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Medicines'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final medication = medications[index];
                final medicationName =
                    medication['name'].toString().toLowerCase();
                final detailsName = medication['medication_details'][0]['name']
                    .toString()
                    .toLowerCase();
                final isMedicationNameMatch =
                    medicationName.contains(searchText.toLowerCase());
                final isDetailsNameMatch =
                    detailsName.contains(searchText.toLowerCase());

                if (!isMedicationNameMatch && !isDetailsNameMatch) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showFullScreenImageDialog(
                          medication['medication_details'][0],
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            _decodeImage(
                              medication['medication_details'][0]['image'],
                              medication['medication_details'][0],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DefaultTextStyle(
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: CupertinoColors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                    child: Text(
                                      '${medication['name']}',
                                    ),
                                  ),
                                  DefaultTextStyle(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                    ),
                                    child: Text(
                                      '${medication['category']}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _viewMedicationDetails(context, medication);
                              },
                              child: const Text('View'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ],
                );
              },
              childCount: medications.length,
            ),
          ),
        ],
      ),
    );
  }

  void _viewMedicationDetails(BuildContext context, dynamic medication) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => MedicationDetailsScreen(medication: medication),
      ),
    );
  }

  void _showFullScreenImageDialog(Map<String, dynamic> details) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Image.network(details['image']),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '${details['type']} ${details['name']} ${details['presentation']} ${details['presentationUnit']}',
              style: const TextStyle(color: CupertinoColors.systemGrey2),
            ),
          ),
        ],
      ),
    );
  }
}
