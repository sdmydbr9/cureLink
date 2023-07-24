import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'fetch.dart';

class TradeNameWidget extends StatefulWidget {
  @override
  _TradeNameWidgetState createState() => _TradeNameWidgetState();
}

class _TradeNameWidgetState extends State<TradeNameWidget> {
  String? selectedType;
  String? selectedName;
  List<String> types = [];
  List<Map<String, dynamic>> names = [];
  List<dynamic> medicationDetails = [];
  TextEditingController _typeAheadController1 = TextEditingController();
  TextEditingController _typeAheadController2 = TextEditingController();
  FocusNode _typeAheadFocusNode = FocusNode();

  bool isLoading = true;
  bool isPickerExited = false;

  @override
  void initState() {
    super.initState();
    fetchTypes().then((result) {
      setState(() {
        types = result;
        isLoading = false;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchNamesByTypeAPI(String type) async {
    List<Map<String, dynamic>> result = await fetchNamesByType(type);
    return result;
  }

  Future<dynamic> fetchMedicationDetailsByNameAPI(String name) async {
    dynamic result = await fetchMedicationDetailsByName(name);
    return result;
  }

  void selectType(String type) {
    setState(() {
      selectedType = type;
      selectedName = '';
      medicationDetails = [];
      _typeAheadController1.text = type;
      _typeAheadController2.text = '';
      isPickerExited = false;
    });

    fetchNamesByTypeAPI(selectedType!).then((fetchedNames) {
      setState(() {
        names = fetchedNames;
      });
    });

    FocusScope.of(context).requestFocus(_typeAheadFocusNode);
  }

  void onPickerExit() {
    setState(() {
      isPickerExited = true;
    });
  }

  void showMedicationDetailsDialog() {
    if (medicationDetails.isEmpty || selectedName == null || !isPickerExited) {
      return;
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Material(
              child: CupertinoAlertDialog(
                title: Text('Medication Details'),
                content: SingleChildScrollView(
                  child: Column(
                    children: medicationDetails.map((medication) {
                      String additionalLine = '';
                      if (medication['type'] == 'Reconstitutable injectables' ||
                          medication['type'] == 'Reconstitutable solution') {
                        String value = medication['value'];
                        additionalLine = value.isNotEmpty
                            ? 'Diluted in $value ml distilled water'
                            : '';
                      }
                      return ListTile(
                        title: Text(
                            '${medication['type']} ${medication['name']} ${medication['presentation'] != null ? medication['presentation'] : ''} ${medication['presentation_unit'] != null ? medication['presentation_unit'] : ''}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (medication['type'] !=
                                'Reconstitutable injectables')
                              Text(
                                  'Contains ${medication['composition']} ${medication['concentration'] != null ? '@ ${medication['concentration']} ${medication['unit']}' : ''}'),
                            if (medication['type'] ==
                                'Reconstitutable injectables')
                              Text(
                                  'Contains ${medication['composition']} ${medication['concentration'] != null ? '@ ${medication['concentration']} ${medication['unit']}' : ''}'),
                            if (medication['type'] ==
                                    'Reconstitutable injectables' ||
                                medication['type'] ==
                                    'Reconstitutable solution')
                              Text('Reconstitution: $additionalLine'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  Container(
                    alignment: Alignment.center,
                    child: CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TypeAheadField<String>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController1,
              decoration: InputDecoration(
                labelText: 'Select Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            suggestionsCallback: (pattern) async {
              return types
                  .where((type) =>
                      type.toLowerCase().startsWith(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (String suggestion) {
              selectType(suggestion);
            },
          ),
          SizedBox(height: 16),
          TypeAheadField<Map<String, dynamic>>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController2,
              focusNode: _typeAheadFocusNode,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              autofocus: false,
            ),
            suggestionsCallback: (pattern) async {
              return names
                  .where((name) => name['name']
                      .toLowerCase()
                      .startsWith(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion['name']),
                subtitle: Text(
                  'Presentation: ${suggestion['presentation']} ${suggestion['presentation_unit']}',
                ),
              );
            },
            onSuggestionSelected: (Map<String, dynamic> suggestion) async {
              setState(() {
                selectedName = suggestion['name'];
                _typeAheadController2.text = suggestion['name'];
              });

              dynamic result =
                  await fetchMedicationDetailsByNameAPI(selectedName!);
              setState(() {
                medicationDetails = result;
              });

              // Call the showMedicationDetailsDialog() function here
              showMedicationDetailsDialog();
            },
            loadingBuilder: (context) {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: CupertinoActivityIndicator(),
              );
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              dynamic result =
                  await fetchMedicationDetailsByNameAPI(selectedName!);
              setState(() {
                medicationDetails = result;
                isPickerExited =
                    true; // Set the flag to indicate picker is exited
              });

              // Call the showMedicationDetailsDialog() function here
              showMedicationDetailsDialog();
            },
            child: Text('Show Medication Details'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade Name Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Trade Name Widget'),
        ),
        body: TradeNameWidget(),
      ),
    );
  }
}
