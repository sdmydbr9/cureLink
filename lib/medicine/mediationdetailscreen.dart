import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final dynamic medication;

  MedicationDetailsScreen({required this.medication});

  @override
  _MedicationDetailsScreenState createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  bool _isScrolledDown = false; // Initialize the scroll state

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

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CupertinoColors.black,
                  ),
                ),
                trailing: Visibility(
                  visible: _isScrolledDown,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 64, 221),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CupertinoButton(
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 16),
                        _buildTopSection(widget.medication),
                        SizedBox(height: 40),
                        _buildSecondarySection(),
                        SizedBox(
                            height:
                                40), // Add some spacing after the secondary section
                        _buildDosageAndDetailsPairs(
                          widget.medication['dosage'],
                          widget.medication['medication_details'],
                        ),
                      ],
                    ),
                  ),
                ),
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
                  : Placeholder(), // You can replace Placeholder with any default image widget
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication['name'].toString().replaceFirst(
                        medication['name'].toString()[0],
                        medication['name'].toString()[0].toUpperCase()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: CupertinoColors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${medication['category'].toString().replaceFirst(medication['category'].toString()[0], medication['category'].toString()[0].toUpperCase())}',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey3,
                    ),
                  ),
                  SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        15), // Adjust the radius value as per your preference
                    child: CupertinoButton(
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                      color: Color.fromARGB(
                          255, 0, 64, 221), // Set the color to blue
                      child: Text('Calculate'),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        // Space between button and divider
        Divider(color: CupertinoColors.systemGrey), // Divider line
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: CupertinoColors.black),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: CupertinoColors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
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
                autoPlay: false,
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
        Divider(color: Colors.grey),

        // Display all dosages
        ...dosages.map((dosage) => _buildDosageTile(dosage)).toList(),
      ],
    );
  }

  Widget _buildDosageTile(Map<String, dynamic> dosage) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dosage['species']} Dosage: ${dosage['dosage']} ${dosage['unit']} per ${dosage['bodyWeight']} ${dosage['weightUnit']} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Route: ${dosage['route']}',
            style: TextStyle(
              color: CupertinoColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationDetailsTile(Map<String, dynamic> details) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [],
      ),
    );
  }
}
