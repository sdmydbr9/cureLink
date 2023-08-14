import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'popup_utils.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final dynamic medication;

  MedicationDetailsScreen({required this.medication});

  @override
  _MedicationDetailsScreenState createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  bool _isScrolledDown = false; // Initialize the scroll state
  int _lowerDoseRate = 0;
  int _upperDoseRate = 0;
  List<dynamic> _medications = [];
  Future<Map<String, dynamic>>? _medicationInfoFuture;
  Future<List<String>>? _recommendedForFuture;

  String _calculationResult = '';
  TextEditingController _resultController = TextEditingController();

  // Listen to the scroll position and update the _isScrolledDown variable accordingly
  void _handleScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels > 0) {
        // Scrolled down
        setState(() {
          _isScrolledDown = true;
        });
      } else {
        // Scrolled up to the top
        setState(() {
          _isScrolledDown = false;
        });
      }
    }
  }

  // Helper function to fetch additional information from the API
  Future<Map<String, dynamic>> _fetchAdditionalInfo(
      String medicationName) async {
    final String apiUrl =
        'https://pethealthwizard.tech:8082/get_info_by_name?name=$medicationName';

    print(
        'API URL for Additional Info: $apiUrl'); // Debug message to print the API URL before making the request

    final response = await http.get(Uri.parse(apiUrl));

    print(
        'Response Body: ${response.body}'); // Debug message to print the response body

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to fetch additional information');
    }
  }

  Future<List<String>> fetchRecommendedFor(String medicationName) async {
    String url =
        'https://pethealthwizard.tech:8082/get_info_by_name?name=$medicationName';
    print('API URL: $url');

    final response = await http.get(Uri.parse(url));
    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Decoded JSON Data: $data');

      final selectedSpecies = data['selectedSpecies'] as String;
      print('Selected Species: $selectedSpecies');

      final recommendedFor =
          selectedSpecies.split(',').map((s) => s.trim()).toList();
      print('Recommended For List: $recommendedFor');

      return recommendedFor;
    } else {
      throw Exception('Failed to load medication data');
    }
  }

  @override
  void initState() {
    super.initState();
    String medicationName = widget.medication['name'].toString();
    print('Medication Name: $medicationName');
    _medicationInfoFuture = fetchMedicationInfo(medicationName);
    _recommendedForFuture = fetchRecommendedFor(medicationName);
  }

  Future<Map<String, dynamic>> fetchMedicationInfo(
      String medicationName) async {
    String url =
        'https://pethealthwizard.tech:8082/get_info_by_name?name=$medicationName';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load medication data');
    }
  }

  void updateResultCard(
    String formattedResult,
    String medicationName,
    String species,
    int lowerDoseRate,
    int upperDoseRate,
    List<dynamic> medications,
  ) {
    print('Updating result card in MedicationDetailsScreen: $formattedResult');

    // Set the calculation result to the local variable
    setState(() {
      _calculationResult = formattedResult;
      _lowerDoseRate = lowerDoseRate;
      _upperDoseRate = upperDoseRate;
      _medications = medications;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Build method called in _MedicationDetailsScreenState.');

    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScroll(notification);
          return true;
        },
        child: CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                largeTitle: Text(
                  widget.medication['name'].toString().replaceFirst(
                      widget.medication['name'].toString()[0],
                      widget.medication['name'].toString()[0].toUpperCase()),
                  style: const TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.black,
                  ),
                ),
                trailing: Visibility(
                  visible: _isScrolledDown,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 64, 221),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CupertinoButton(
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              PopupCalculatorScreen(
                            medicationName:
                                widget.medication['name'].toString(),
                            updateResultCard: updateResultCard,
                            onMedicationInfoChanged: (species, bodyWeight) {
                              // Implement the logic you want to execute when medication info changes
                              // For example, you can call performMedicationCalculation here
                              // with the updated species and bodyWeight.
                            },
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildTopSection(widget.medication),
                        const SizedBox(height: 40),
                        _buildSecondarySection(),
                        const SizedBox(
                            height:
                                40), // Add some spacing after the secondary section
                        _buildDosageAndDetailsPairs(
                          widget.medication['dosage'],
                          widget.medication['medication_details'],
                        ),
                        const SizedBox(height: 40),
                        _buildMedicationDetailsSection(widget.medication),
                        const SizedBox(
                            height: 16), // Add some extra spacing at the bottom
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildResultSection(), // Display the result section
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(dynamic medication) {
    String? firstImageUrl;

    if (medication['medication_details'] != null &&
        medication['medication_details'].isNotEmpty) {
      firstImageUrl = medication['medication_details'][0]['image'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: 120,
              child: firstImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                          18), // Set the corner radius as per your preference
                      child: Image.network(
                        firstImageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Placeholder(), // You can replace Placeholder with any default image widget
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication['name'].toString().replaceFirst(
                        medication['name'].toString()[0],
                        medication['name'].toString()[0].toUpperCase()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medication['category'].toString().replaceFirst(medication['category'].toString()[0], medication['category'].toString()[0].toUpperCase())}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey3,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CupertinoButton(
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return PopupCalculatorScreen(
                              medicationName:
                                  widget.medication['name'].toString(),
                              updateResultCard: updateResultCard,
                              onMedicationInfoChanged: (species, bodyWeight) {
                                // Implement the logic you want to execute when medication info changes
                                // For example, you can call performMedicationCalculation here
                                // with the updated species and bodyWeight.
                              },
                            );
                          },
                        );
                      },
                      color: const Color.fromARGB(255, 0, 64, 221),
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        // Space between button and divider
        const Divider(color: CupertinoColors.systemGrey), // Divider line
      ],
    );
  }

  Widget _buildSecondarySection() {
    String formattedCategory =
        '${widget.medication['category'].toString().replaceFirst(widget.medication['category'].toString()[0], widget.medication['category'].toString()[0].toUpperCase())}';

    return FutureBuilder<Map<String, dynamic>>(
      future: _medicationInfoFuture,
      builder: (context, medicationSnapshot) {
        if (medicationSnapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.tag,
                    'Category',
                    formattedCategory,
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.eye,
                    'MOA',
                    'View',
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.exclamationmark_octagon_fill,
                    'Contraindication',
                    'View',
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.person_2_fill,
                    'Recommended for',
                    'Loading...', // Show loading message while fetching data
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.bolt_fill,
                    'Common Side Effect',
                    'View',
                  ),
                ),
              ],
            ),
          );
        } else if (medicationSnapshot.hasError) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.tag,
                    'Category',
                    formattedCategory,
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.eye,
                    'MOA',
                    'View',
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.exclamationmark_octagon_fill,
                    'Contraindication',
                    'View',
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.person_2_fill,
                    'Recommended for',
                    'Error loading data', // Show error message if API call fails
                  ),
                ),
                Flexible(
                  child: _buildSection(
                    CupertinoIcons.bolt_fill,
                    'Common Side Effect',
                    'View',
                  ),
                ),
              ],
            ),
          );
        } else {
          Map<String, dynamic> medicationInfo = medicationSnapshot.data!;

          return FutureBuilder<List<String>>(
            future: _recommendedForFuture,
            builder: (context, recommendedForSnapshot) {
              if (recommendedForSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.tag,
                          'Category',
                          formattedCategory,
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.eye,
                          'Mechanism',
                          'View',
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.exclamationmark_octagon_fill,
                          'Contraindication',
                          'View',
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.person_2_fill,
                          'Recommended for',
                          'Loading...', // Show loading message while fetching recommended for data
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.bolt_fill,
                          'Side Effect',
                          'View',
                        ),
                      ),
                    ],
                  ),
                );
              } else if (recommendedForSnapshot.hasError) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.tag,
                          'Category',
                          formattedCategory,
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.eye,
                          'Mechanism',
                          'View',
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.exclamationmark_octagon_fill,
                          'Contraindication',
                          'View',
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.person_2_fill,
                          'Recommended for',
                          'Error loading data', // Show error message if recommended for API call fails
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.bolt_fill,
                          'Side Effect',
                          'View',
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                List<String> recommendedFor = recommendedForSnapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.tag,
                          'Category',
                          formattedCategory,
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.eye,
                          'Mechanism',
                          'View',
                          onTap: () => _showPopup(
                              medicationInfo['mechanismOfAction'], 'Mechanism'),
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.exclamationmark_octagon_fill,
                          'Contraindication',
                          'View',
                          onTap: () => _showPopup(
                              medicationInfo['contraindication'],
                              'Contraindication'),
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.person_2_fill,
                          'Recommended for',
                          recommendedFor.join(
                              ', '), // Join the recommendedFor list with commas
                          // No onTap callback for Recommended for section
                        ),
                      ),
                      Flexible(
                        child: _buildSection(
                          CupertinoIcons.bolt_fill,
                          'Side Effect',
                          'View',
                          onTap: () => _showPopup(
                              medicationInfo['commonSideEffects'],
                              'Side Effect'),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  void _showPopup(String? data, String title) {
    bool showMoreInfo = false;
    final double minHeight = 256.0; // The initial height of the popup
    double currentHeight = minHeight;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  showMoreInfo =
                      details.delta.dy < 0; // Check if the drag is upwards
                  currentHeight = showMoreInfo ? 400.0 : minHeight;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                    milliseconds: 300), // Animation duration in milliseconds
                height: currentHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 56.0, // Fixed height for the top bar
                      color: CupertinoColors.systemBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Details',
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .navTitleTextStyle
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(CupertinoIcons.clear),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPopupSurface(
                        isSurfacePainted: true,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.black,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Display the content here
                                // ...
                                Text(
                                  data ?? 'No data available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .black, // Use your preferred text color
                                    fontWeight: FontWeight
                                        .normal, // Use your preferred font weight
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CupertinoButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close the popup when "Close" button is pressed
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection(IconData iconData, String title, String content,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(iconData, color: CupertinoColors.inactiveGray),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: CupertinoColors.inactiveGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get the icon path based on species name
  String? getSpeciesIconPath(String species) {
    switch (species) {
      case 'Dogs':
        return 'assets/icons/dalmatian.png';
      case 'Cats':
        return 'assets/icons/cat.png';
      case 'Cattle':
        return 'assets/icons/cow.png';
      case 'Caprine':
        return 'assets/icons/goat.png';
      case 'Horse':
        return 'assets/icons/horse.png';
      case 'Rabbits':
        return 'assets/icons/rabbit.png';
      case 'Avian':
        return 'assets/icons/hen.png';
      case 'Pigs':
        return 'assets/icons/pig.png';
      default:
        return null; // Return null if the species name is not matched
    }
  }

  Widget _buildResultSection() {
    // Check if there are any calculation results to display
    if (_calculationResult.isEmpty) {
      return Container(); // If there are no results, return an empty container
    }

    // Find the index of the medication name within the calculation result
    final int medicationNameIndex =
        _calculationResult.indexOf(widget.medication['name'].toString());

    // Find the index of the "Species:" label within the calculation result
    final int speciesLabelIndex = _calculationResult.indexOf("Species:");

    // Find the index of the species name within the calculation result
    final int speciesNameIndex = speciesLabelIndex + "Species:".length;

    // Find the index of the next line break after the species name
    final int nextLineBreakIndex =
        _calculationResult.indexOf("\n", speciesNameIndex);

    // Extract the species information
    final String species = _calculationResult
        .substring(speciesNameIndex, nextLineBreakIndex)
        .trim();

    // Get the icon path for the species
    final String? speciesIconPath = getSpeciesIconPath(species);

    // Extract the medication name
    final String medicationName = _calculationResult.substring(
      medicationNameIndex,
      medicationNameIndex + widget.medication['name'].toString().length,
    );
    // Capitalize the first letter of the medication name
    final String capitalizedMedicationName =
        medicationName[0].toUpperCase() + medicationName.substring(1);

    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the species icon and name at the top and center it
            Center(
              child: Column(
                children: [
                  if (speciesIconPath != null)
                    Image.asset(
                      speciesIconPath,
                      width: 40, // Adjust the width as needed
                      height: 40, // Adjust the height as needed
                    ),
                  Text(
                    species,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // Center the medication name and display the first alphabet as capital
            Center(
              child: Text(
                capitalizedMedicationName,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 16.0, color: CupertinoColors.black),
                children: [
                  TextSpan(
                    text: _calculationResult.substring(nextLineBreakIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageAndDetailsPairs(
    List<dynamic> dosages,
    List<dynamic> details,
  ) {
    List<String>? imageUrls = [];

    // Extract image URLs from medication details
    if (details != null && details.isNotEmpty) {
      imageUrls = details
          .map((detail) => detail['image'] ?? '')
          .cast<String>()
          .toList();
    }

    final CarouselController _carouselController = CarouselController();

    return ListView(
      // Wrap ExpandedDosageCard with ListView
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
      children: [
        // Display the carousel with images
        Container(
          height: 500, // Fixed height for the container
          child: AspectRatio(
            aspectRatio: 9 / 16, // Portrait aspect ratio (9:16)
            child: CarouselSlider(
              carouselController: _carouselController,
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width -
                          40, // Adjust the width to decrease spacing
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 9 / 16, // Set the aspect ratio to 9:16 (portrait)
                enlargeCenterPage: true,
                enableInfiniteScroll:
                    true, // Set to false if you don't want infinite scrolling
                viewportFraction:
                    0.8, // Adjust the fraction to decrease spacing between slides
              ),
            ),
          ),
        ),

        // Add a divider between details and dosage
        const Divider(color: Colors.grey),

        // Display all dosages
        ...dosages.map((dosage) => GestureDetector(
              onTap: () {
                // Show dosage information in a dialog when tapped
                _showDosageDialog(dosage);
              },
              child: _buildDosageTile(dosage, speciesIconMap),
            )),
      ],
    );
  }

  void _showDosageDialog(Map<String, dynamic> dosage) async {
    final String species = dosage['species'];
    final String iconFileName = speciesIconMap[species] ?? 'default.png';

    bool showMoreInfo = false;
    final double minHeight = 250.0;
    double currentHeight = minHeight;

    // Cached additional information
    Map<String, dynamic>? cachedAdditionalInfo;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  if (!showMoreInfo) {
                    showMoreInfo = details.delta.dy < 0;
                    currentHeight = showMoreInfo
                        ? MediaQuery.of(context).size.height
                        : minHeight;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: currentHeight,
                child: CupertinoPopupSurface(
                  isSurfacePainted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Stretch the top bar to full width
                    children: [
                      // Non-scrollable "Details" heading
                      GestureDetector(
                        // Vertical drag to open and close the pop-up
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            if (!showMoreInfo) {
                              showMoreInfo = true;
                              currentHeight =
                                  MediaQuery.of(context).size.height;
                            } else {
                              showMoreInfo = false;
                              currentHeight = minHeight;
                            }
                          });
                        },
                        child: Container(
                          color: CupertinoColors.systemBackground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 2.0), // Adjust padding here
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Details',
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .navTitleTextStyle
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.black,
                                    ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(CupertinoIcons.clear),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1), // Divider
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.black,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/icons/$iconFileName',
                                          width: 48,
                                          height: 48,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${dosage['species']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dosage: ${dosage['dosage']} ${dosage['unit']} / ${dosage['bodyWeight']} ${dosage['weightUnit']}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Route: ${dosage['route']}',
                                  ),
                                  const SizedBox(height: 8),
                                  if (showMoreInfo)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        // Use cached data if available
                                        if (cachedAdditionalInfo != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'MOA: ${cachedAdditionalInfo!['mechanismOfAction']}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'Contraindication: ${cachedAdditionalInfo!['contraindication']}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'Indication: ${cachedAdditionalInfo!['indication']}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'Common Side Effect: ${cachedAdditionalInfo!['commonSideEffects']}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'More Info: ${cachedAdditionalInfo!['moreInfo']}'),
                                              const SizedBox(height: 8),
                                            ],
                                          )
                                        else
                                          FutureBuilder(
                                            future: _fetchAdditionalInfo(widget
                                                .medication['name']
                                                .toString()),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CupertinoActivityIndicator(); // Replace with Cupertino loading indicator
                                              } else if (snapshot.hasError) {
                                                return const Text(
                                                    'Failed to fetch additional information');
                                              } else {
                                                final responseData =
                                                    snapshot.data;
                                                cachedAdditionalInfo =
                                                    responseData; // Cache fetched data

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'MOA: ${responseData!['mechanismOfAction']}'),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        'Contraindication: ${responseData['contraindication']}'),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        'Indication: ${responseData['indication']}'),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        'Common Side Effect: ${responseData['commonSideEffects']}'),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        'More Info: ${responseData['moreInfo']}'),
                                                    const SizedBox(height: 8),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  if (!showMoreInfo)
                                    CupertinoButton(
                                      onPressed: () {
                                        setState(() {
                                          showMoreInfo = true;
                                          currentHeight = MediaQuery.of(context)
                                              .size
                                              .height;
                                        });
                                      },
                                      child: const Text('More'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  final Map<String, String> speciesIconMap = {
    'Dogs': 'dalmatian.png',
    'Cats': 'cat.png',
    'Cattle': 'cow.png',
    'Caprine': 'goat.png',
    'Horse': 'horse.png',
    'Rabbits': 'rabbit.png',
    'Avian': 'hen.png',
    'Pigs': 'pig.png',
  };
}

Widget _buildDosageTile(
    Map<String, dynamic> dosage, Map<String, String> speciesIconMap) {
  String species = dosage['species'];
  String iconFileName = speciesIconMap[species] ?? 'default.png';

  return Card(
    elevation: 4, // Add some shadow to the card for a raised effect
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners for the card
    ),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/$iconFileName',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$species Dosage: ${dosage['dosage']} ${dosage['unit']} / ${dosage['bodyWeight']} ${dosage['weightUnit']} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Route: ${dosage['route']}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Map to associate medication types with corresponding asset paths
final Map<String, String> medicationTypeIcons = {
  'Inj': 'assets/icons/injection.png',
  'syrup': 'assets/icons/syrup.png',
  'Vial': 'assets/icons/vial.png',
  'Reconstitutable injectables': 'assets/icons/vaccine.png',
  'Tab': 'assets/icons/drugs.png',
  'Shampoo': 'assets/icons/soap.png',
};

Widget _buildMedicationDetailsSection(dynamic medication) {
  List<dynamic> medicationDetails = medication['medication_details'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 8),
      for (var detail in medicationDetails)
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication Type Icon
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    medicationTypeIcons[detail['type']] ??
                        'assets/icons/default.png',
                    width: 24,
                    height: 24,
                    // You can customize the width and height according to your preference
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${detail['name']} ${detail['presentation']} ${detail['presentationUnit']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Concentration: ${detail['concentration']} ${detail['unit']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presentation: ${detail['presentation']} ${detail['presentationUnit']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 8), // Add spacing between details
                    ],
                  ),
                ),
                const SizedBox(
                    width: 8), // Add spacing between the icon and text
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      18), // Adjust the radius as per your preference
                  child: Image.network(
                    detail['image'],
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget _buildMedicationDetailsTile(Map<String, dynamic> details) {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [],
    ),
  );
}
