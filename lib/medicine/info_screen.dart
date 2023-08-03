import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'process_info.dart';
import 'cupertino_typeahead.dart';

void main() => runApp(const SliverNavBarApp());

class SliverNavBarApp extends StatelessWidget {
  const SliverNavBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: MedicineInfo(),
    );
  }
}

class Medication {
  final String medicationName;

  Medication({required this.medicationName});
}

class MedicineInfo extends StatefulWidget {
  const MedicineInfo({super.key});

  @override
  _MedicineInfoState createState() => _MedicineInfoState();
}

class _MedicineInfoState extends State<MedicineInfo> {
  final TextEditingController _compoundController = TextEditingController();
  String? selectedMedicationName;
  ScrollController _scrollController = ScrollController();
  bool _showMedicationName = false;
  List<String> selectedSpecies = [];
  String selectedSpeciesText = 'Select Species';
  List<Medication> _medicationList = <Medication>[];

  // Declare variables to store values entered in the fields
  String? _mechanismOfAction;
  String? _contraindication;
  String? _indication;
  String? _commonSideEffects;
  String? _moreInfo;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Determine if the medication name should be shown or not based on the scroll offset
    setState(() {
      _showMedicationName = _scrollController.offset > 100;
    });
  }

  void _handleSubmit() {
    // Get the entered values from the text fields and selected species
    String compoundName = _compoundController.text;
    String selectedSpecies = selectedSpeciesText;

    // Print the entered values (for demonstration purposes)
    print('Compound Name: $compoundName');
    print('Selected Species: $selectedSpecies');
    print('Mechanism of Action: $_mechanismOfAction');
    print('Contraindication: $_contraindication');
    print('Indication: $_indication');
    print('Common Side Effects: $_commonSideEffects');
    print('More Info: $_moreInfo');

    // Navigate to the process_med_info.dart screen and pass the entered information
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ProcessMedInfo(
          compoundName: compoundName,
          selectedSpecies: selectedSpecies,
          mechanismOfAction: _mechanismOfAction ?? '',
          contraindication: _contraindication ?? '',
          indication: _indication ?? '',
          commonSideEffects: _commonSideEffects ?? '',
          moreInfo: _moreInfo ?? '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedications() async {
    String url = 'https://pethealthwizard.tech:8082/fetch_compound_name';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      List<String> medications = List<String>.from(data);

      setState(() {
        _medicationList.addAll(medications.map(
            (medicationName) => Medication(medicationName: medicationName)));
      });
    }
  }

  Future<List<Medication>> _fetchMedicationsSuggestions(String query) async {
    return _medicationList
        .where((medication) => medication.medicationName
            .toLowerCase()
            .startsWith(query.toLowerCase()))
        .map((medication) =>
            Medication(medicationName: medication.medicationName))
        .toList();
  }

  void _showSpeciesPopup(BuildContext context) {
    final double halfScreenHeight = MediaQuery.of(context).size.height * 0.75;
    double currentHeight = halfScreenHeight;

    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  currentHeight = halfScreenHeight - details.delta.dy;
                  if (currentHeight < 0) {
                    // Set a minimum height for the popup
                    currentHeight = 0;
                  }
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  // After the drag ends, reset the height to half-screen or full-screen
                  currentHeight =
                      currentHeight < halfScreenHeight ? 0 : halfScreenHeight;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: currentHeight,
                child: CupertinoPopupSurface(
                  isSurfacePainted: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Recommended for'),
                          _buildSwitchTile('Dog', 'dog', setState),
                          _buildSwitchTile('Cat', 'cat', setState),
                          _buildSwitchTile('Goat', 'goat', setState),
                          _buildSwitchTile('Sheep', 'sheep', setState),
                          _buildSwitchTile('Pig', 'pig', setState),
                          _buildSwitchTile('Horse', 'horse', setState),
                          _buildSwitchTile('Cow', 'cow', setState),
                          _buildSwitchTile('Buffalo', 'buffalo', setState),
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                selectedSpeciesText = selectedSpecies.isNotEmpty
                                    ? selectedSpecies.join(', ')
                                    : 'species';
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Done'),
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

  Widget _buildSwitchTile(
      String title, String speciesValue, StateSetter setState) {
    final bool isSelected = selectedSpecies.contains(speciesValue);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        CupertinoSwitch(
          value: isSelected,
          onChanged: (bool value) {
            setState(() {
              if (value) {
                selectedSpecies.add(speciesValue);
              } else {
                selectedSpecies.remove(speciesValue);
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        controller:
            _scrollController, // Attach the scroll controller to the CustomScrollView
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading: _showMedicationName
                ? Text(selectedMedicationName ??
                    '') // Show the medication name when scrolled
                : null,
            largeTitle: const Text('info add'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 16),
                  CupertinoTypeAhead<Medication>(
                    controller: _compoundController,
                    suggestionsCallback: _fetchMedicationsSuggestions,
                    itemBuilder: (context, medication) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(medication.medicationName),
                      );
                    },
                    onSuggestionSelected: (medication) {
                      setState(() {
                        selectedMedicationName = medication
                            .medicationName; // Update selected medication name
                        _compoundController.text = medication.medicationName;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showSpeciesPopup(context);
                    },
                    child: _buildSelectSpeciesField(),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'MOA (Mechanism of Action)',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        // Save the mechanism of action value when it changes
                        _mechanismOfAction = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'Contraindication',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        // Save the contraindication value when it changes
                        _contraindication = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'Indication',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        // Save the indication value when it changes
                        _indication = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'Common Side Effects',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        // Save the common side effects value when it changes
                        _commonSideEffects = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'More Info...',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        // Save the more info value when it changes
                        _moreInfo = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    onPressed: _handleSubmit,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSpeciesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended for',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        GestureDetector(
          onTap: () {
            _showSpeciesPopup(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoColors.systemGrey2,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSpeciesText,
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.black,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
