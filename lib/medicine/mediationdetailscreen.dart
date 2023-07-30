import 'package:cure_link/medicine/popup_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'popup_utils.dart';
import 'calculation_result_card.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final dynamic medication;

  MedicationDetailsScreen({required this.medication});

  @override
  _MedicationDetailsScreenState createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  bool _isScrolledDown = false; // Initialize the scroll state

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

  void updateResultCard(String formattedResult) {
    print('Updating result card in MedicationDetailsScreen: $formattedResult');

    // Set the calculation result to the local variable
    _calculationResult = formattedResult;

    // Split the formattedResult into individual medication results
    List<String> medicationResults = formattedResult.split('\n\n');

    // Add a new CalculationResultCard for each medication result

    setState(() {
      // No need to add anything here; we already updated the resultCards list above
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
                              updateResultCard:
                                  updateResultCard, // Pass the updateResultCard function
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSection(CupertinoIcons.tag, 'Category', 'Category placeholder'),
          _buildSection(CupertinoIcons.eye, 'MOA', 'MOA placeholder'),
          _buildSection(CupertinoIcons.exclamationmark_octagon_fill,
              'Contraindication', 'Contraindication placeholder'),
          _buildSection(CupertinoIcons.person_2_fill, 'Recommended for',
              'Recommended for placeholder'),
          _buildSection(CupertinoIcons.bolt_fill, 'Common Side Effect',
              'Common Side Effect placeholder'),
        ],
      ),
    );
  }

  Widget _buildSection(IconData iconData, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align items at the center
        children: [
          Align(
            alignment: Alignment.center, // Center the icon
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
    );
  }

  Widget _buildResultSection() {
    // Check if there are any calculation results to display
    if (_calculationResult.isEmpty) {
      return Container(); // If there are no results, return an empty container
    }

    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculation Result:',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              _calculationResult ?? 'No results yet',
              style: const TextStyle(fontSize: 16.0),
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

  void _showDosageDialog(Map<String, dynamic> dosage) {
    final String species = dosage['species'];
    final String iconFileName = speciesIconMap[species] ??
        'default.png'; // Get the icon filename for the species

    bool showMoreInfo = false;

    final double minHeight = 200.0; // The initial height of the popup
    double currentHeight = minHeight;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                // Detect vertical drag and update the showMoreInfo state accordingly
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
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Align children in the center
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Display the icon and species in the center
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
                                Text(
                                  '${dosage['species']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text('MOA: Placeholder'),
                                const SizedBox(height: 8),
                                const Text('Contraindication: Placeholder'),
                                const SizedBox(height: 8),
                                const Text('Indication: Placeholder'),
                                const SizedBox(height: 8),
                                const Text('Common Side Effect: Placeholder'),
                                const SizedBox(height: 8),
                              ],
                            ),

                          CupertinoButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Close the popup when "Info" button is pressed
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
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
    'Sheep/Goat': 'goat.png',
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
