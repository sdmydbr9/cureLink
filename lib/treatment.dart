import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom.dart';

class TreatmentDialog extends StatefulWidget {
  final Function(List<Treatment>) onTreatmentSelected;
  final List<Treatment> previousTreatments;

  const TreatmentDialog({
    Key? key,
    required this.onTreatmentSelected,
    required this.previousTreatments,
  }) : super(key: key);

  @override
  _TreatmentDialogState createState() => _TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog> {
  List<Treatment> treatmentEntries = [];
  List<List<TextEditingController>> textEditingControllers = [];
  late Size screenSize;

  bool _isFormValid() {
    for (var treatment in treatmentEntries) {
      if (treatment.type == null ||
          treatment.name == null ||
          treatment.number == null ||
          treatment.unit == null ||
          (treatment.days != null &&
              treatment.days!.isNotEmpty &&
              treatment.months != null &&
              treatment.months!.isNotEmpty) ||
          (treatment.days != null &&
              treatment.days!.isNotEmpty &&
              treatment.customDays != null &&
              treatment.customDays!.isNotEmpty) ||
          (treatment.months != null &&
              treatment.months!.isNotEmpty &&
              treatment.customDays != null &&
              treatment.customDays!.isNotEmpty)) {
        return false;
      }
    }
    return true;
  }

  List<String> treatmentTypes = [
    'inj',
    'tab',
    'syrup',
    'shampoo',
    'powder',
    'lotion',
    'ointment',
  ];

  List<String> treatmentUnits = [
    'vial',
    'strip',
    'bottle',
    'packet',
    'tube',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.previousTreatments.isNotEmpty) {
      treatmentEntries = List.from(widget.previousTreatments);
    } else {
      treatmentEntries.add(Treatment());
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Get the screen size after the layout is built
      setState(() {
        screenSize = MediaQuery.of(context).size;
      });
    });

    // Initialize text editing controllers with the initial values
    for (int i = 0; i < treatmentEntries.length; i++) {
      List<TextEditingController> controllers = [];
      controllers.add(TextEditingController(
        text: treatmentEntries[i].name ?? '',
      ));
      controllers.add(TextEditingController(
        text: treatmentEntries[i].sig ?? '',
      ));
      controllers.add(TextEditingController(
        text: treatmentEntries[i].customDays ?? '',
      ));
      textEditingControllers.add(controllers);
    }
  }

  @override
  void dispose() {
    // Dispose of text editing controllers
    for (List<TextEditingController> controllers in textEditingControllers) {
      for (TextEditingController controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: SizedBox(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.9,
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: treatmentEntries.length,
                  itemBuilder: (context, index) {
                    return _buildTreatmentEntry(index);
                  },
                ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: () {
                    // Add treatment entry to the list
                    setState(() {
                      treatmentEntries.add(Treatment());
                      List<TextEditingController> controllers = [];
                      controllers.add(TextEditingController());
                      controllers.add(TextEditingController());
                      controllers.add(TextEditingController());
                      textEditingControllers.add(controllers);
                    });
                  },
                  child: Text('Add More'),
                ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: _isFormValid()
                      ? () {
                          // Pass the filled-in data to the parent widget
                          widget.onTreatmentSelected(treatmentEntries
                              .where((treatment) =>
                                  treatment.type != null &&
                                  treatment.name != null &&
                                  treatment.number != null &&
                                  treatment.unit != null)
                              .toList());
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentEntry(int index) {
    Treatment treatment = treatmentEntries[index];
    List<TextEditingController> controllers = textEditingControllers[index];

    bool isDaysEditable = true;
    bool isMonthsEditable = true;
    bool isCustomDaysEditable = true;

    if (treatment.days != null && treatment.days!.isNotEmpty) {
      isMonthsEditable = false;
      isCustomDaysEditable = false;
    } else if (treatment.months != null && treatment.months!.isNotEmpty) {
      isDaysEditable = false;
      isCustomDaysEditable = false;
    } else if (treatment.customDays != null &&
        treatment.customDays!.isNotEmpty) {
      isDaysEditable = false;
      isMonthsEditable = false;
    }

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.02),
      child: Container(
        width: screenSize.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Type',
                        index,
                        treatment.type,
                        treatmentTypes,
                      ),
                    ),
                    Expanded(
                      child: _buildTextField(
                        'Name',
                        index,
                        controllers[0],
                      ),
                    ),
                    Expanded(
                      child: _buildNumberField(
                        'Number',
                        index,
                        treatment.number,
                      ),
                    ),
                    Expanded(
                      child: _buildDropdownField(
                        'Unit',
                        index,
                        treatment.unit,
                        treatmentUnits,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _removeTreatmentEntry(index);
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: screenSize.height * 0.01,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Sig',
                    index,
                    controllers[1],
                    isEditable: isDaysEditable,
                  ),
                ),
                Expanded(
                  child: _buildNumberField(
                    'Days',
                    index,
                    treatment.days,
                    isEditable: isMonthsEditable,
                  ),
                ),
                Expanded(
                  child: _buildNumberField(
                    'Months',
                    index,
                    treatment.months,
                    isEditable: isCustomDaysEditable,
                  ),
                ),
                Expanded(
                  child: _buildTextField(
                    'Custom Days',
                    index,
                    controllers[2],
                    isEditable: isCustomDaysEditable,
                    onTap: () {
                      _openCustomTreatmentDialog(index);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomTreatmentDialog(int index) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CustomTreatmentDialog(
        onCustomTreatmentSelected: (customTreatment) {
          setState(() {
            Treatment treatment = treatmentEntries[index];
            treatment.setCustomDays(customTreatment);
            textEditingControllers[index][2].text = customTreatment;
          });
        },
      ),
    );

    if (result != null) {
      setState(() {
        textEditingControllers[index][2].text = result;
      });
    }
  }

  void _removeTreatmentEntry(int index) {
    setState(() {
      treatmentEntries.removeAt(index);
      textEditingControllers.removeAt(index);
    });
  }

  Widget _buildTextField(
    String labelText,
    int index,
    TextEditingController controller, {
    bool isEditable = true,
    Function()? onTap,
  }) {
    if (!isEditable) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.02,
        ),
        child: Text(
          controller.text ?? '',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      bool isCustomDaysField = labelText == 'Custom Days';

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.02,
        ),
        child: TextField(
          controller: controller,
          readOnly: isCustomDaysField,
          decoration: InputDecoration(
            labelText: labelText,
          ),
          textInputAction: TextInputAction.none,
          keyboardType: TextInputType.text,
          onTap: onTap,
          onChanged: (newValue) {
            setState(() {
              Treatment treatment = treatmentEntries[index];
              switch (labelText) {
                case 'Name':
                  treatment.setName(newValue);
                  break;
                case 'Sig':
                  treatment.setSig(newValue);
                  break;
                case 'Custom Days':
                  treatment.setCustomDays(newValue);
                  if (newValue.isNotEmpty) {
                    treatment.setDays('');
                    treatment.setMonths('');
                  }
                  break;
              }
            });
          },
        ),
      );
    }
  }

  Widget _buildNumberField(String labelText, int index, String? value,
      {bool isEditable = true}) {
    if (!isEditable) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.02,
        ),
        child: Text(
          value ?? '',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
          vertical: screenSize.height * 0.02,
        ),
        child: GestureDetector(
          onTap: () {
            _showNumberPickerDialog(index, labelText, value);
          },
          child: Row(
            children: [
              value != null && value.isNotEmpty
                  ? Text(
                      value,
                      style: TextStyle(fontSize: screenSize.height * 0.02),
                    )
                  : Text(
                      labelText,
                      style: TextStyle(
                        fontSize: screenSize.height * 0.02,
                        color: Colors.grey,
                      ),
                    ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      );
    }
  }

  void _showNumberPickerDialog(int index, String labelText, String? value) {
    int initialValue =
        value != null && value.isNotEmpty ? int.parse(value) + 1 : 0;
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(labelText),
          content: Container(
            height: screenSize.height * 0.2,
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: initialValue),
              itemExtent: screenSize.height * 0.032,
              onSelectedItemChanged: (int newValue) {
                setState(() {
                  Treatment treatment = treatmentEntries[index];
                  switch (labelText) {
                    case 'Number':
                      if (newValue > 0) {
                        treatment.setNumber((newValue - 1).toString());
                      } else {
                        treatment.setNumber(null);
                      }
                      break;
                    case 'Days':
                      if (newValue > 0) {
                        treatment.setDays((newValue - 1).toString());
                        treatment.setMonths(null);
                        treatment.setCustomDays(null);
                      } else {
                        treatment.setDays(null);
                      }
                      break;
                    case 'Months':
                      if (newValue > 0) {
                        treatment.setMonths((newValue - 1).toString());
                        treatment.setDays(null);
                        treatment.setCustomDays(null);
                      } else {
                        treatment.setMonths(null);
                      }
                      break;
                  }
                });
              },
              children: List<Widget>.generate(101, (int index) {
                if (index == 0) {
                  return Center(
                    child: Text("None"),
                  );
                } else {
                  return Center(
                    child: Text((index - 1).toString()),
                  );
                }
              }),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField(
      String labelText, int index, String? value, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.02,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        value: value,
        onChanged: (newValue) {
          // Update treatment entry when dropdown value changes
          setState(() {
            Treatment treatment = treatmentEntries[index];
            switch (labelText) {
              case 'Type':
                treatment.setType(newValue!);
                break;
              case 'Unit':
                treatment.setUnit(newValue!);
                break;
            }
          });
        },
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
}

class Treatment {
  String? type;
  String? name;
  String? number;
  String? unit;
  String? sig;
  String? days;
  String? months;
  String? customDays;

  void setType(String? value) {
    type = value;
  }

  void setName(String? value) {
    name = value;
  }

  void setNumber(String? value) {
    number = value;
  }

  void setUnit(String? value) {
    unit = value;
  }

  void setSig(String? value) {
    sig = value;
  }

  void setDays(String? value) {
    days = value;
  }

  void setMonths(String? value) {
    months = value;
  }

  void setCustomDays(String? value) {
    customDays = value;
  }

  @override
  String toString() {
    List<String> fields = [];

    if (type != null) {
      fields.add('$type');
    }

    if (name != null) {
      fields.add('$name');
    }

    if (number != null) {
      fields.add('$number');
    }

    if (unit != null) {
      fields.add('$unit');
    }

    if (sig != null && sig.toString().isNotEmpty) {
      fields.add('Sig: $sig');
    }

    if (days != null && days.toString().isNotEmpty) {
      fields.add('for $days days');
    }

    if (months != null && months.toString().isNotEmpty) {
      fields.add('for $months month');
    }

    if (customDays != null) {
      fields.add(' $customDays');
    }

    return fields.join(' ');
  }
}
