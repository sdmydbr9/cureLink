import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class FrequencyOption {
  final String value;
  final String label;

  FrequencyOption(this.value, this.label);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrequencyOption && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

class CustomTreatmentDialog extends StatefulWidget {
  final Function(String) onCustomTreatmentSelected;

  const CustomTreatmentDialog({
    Key? key,
    required this.onCustomTreatmentSelected,
  }) : super(key: key);

  @override
  _CustomTreatmentDialogState createState() => _CustomTreatmentDialogState();
}

class _CustomTreatmentDialogState extends State<CustomTreatmentDialog> {
  FrequencyOption? selectedFrequency;
  String? selectedOccasions;
  int? selectedNumber;
  DateTime? selectedDate;

  final List<FrequencyOption> frequencies = [
    FrequencyOption('stat', 'Stat'),
    FrequencyOption('every', 'Every'),
    FrequencyOption('after', 'After'),
    FrequencyOption('on', 'On'),
    FrequencyOption('on date', 'On Date'),
    FrequencyOption('weekly', 'Weekly'),
    FrequencyOption('monthly', 'Monthly'),
    FrequencyOption('annually', 'Annually'),
  ];

  bool get shouldShowDayField =>
      selectedFrequency?.value == 'every' ||
      selectedFrequency?.value == 'after' ||
      selectedFrequency?.value == 'on';

  bool get shouldShowOccasionsField =>
      selectedFrequency?.value != 'stat' &&
      selectedFrequency?.value != 'on date';

  void showDateSelector() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Custom days'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Frequency: '),
              Expanded(
                child: DropdownButton<FrequencyOption>(
                  value: selectedFrequency,
                  onChanged: (FrequencyOption? value) {
                    setState(() {
                      selectedFrequency = value;
                      selectedNumber = null;
                      selectedOccasions = null;
                      selectedDate = null;

                      if (selectedFrequency?.value == 'on date') {
                        showDateSelector();
                      }
                    });
                  },
                  items: frequencies.map((FrequencyOption frequency) {
                    return DropdownMenuItem<FrequencyOption>(
                      value: frequency,
                      child: Text(frequency.label),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (shouldShowDayField) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (selectedFrequency?.value == 'on date') {
                        showDateSelector();
                      } else {
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    selectedNumber = index + 1;
                                  });
                                },
                                children:
                                    List<Widget>.generate(31, (int index) {
                                  return Text((index + 1).toString());
                                }),
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          selectedNumber != null
                              ? selectedNumber.toString()
                              : 'Select',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          selectedFrequency?.value == 'on date'
                              ? 'date'
                              : 'day',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (shouldShowOccasionsField) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            child: CupertinoPicker(
                              itemExtent: 40,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  selectedOccasions = (index + 1).toString();
                                });
                              },
                              children: List<Widget>.generate(11, (int index) {
                                return Text((index + 1).toString());
                              }),
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Occasion: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          selectedOccasions != null
                              ? selectedOccasions!
                              : 'Select',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedFrequency = null;
              selectedOccasions = null;
              selectedNumber = null;
              selectedDate = null;
            });
          },
          child: Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            String customTreatmentText = '';

            if (selectedFrequency?.value == 'stat') {
              customTreatmentText += ' Stat';
            } else if (selectedFrequency?.value == 'weekly' ||
                selectedFrequency?.value == 'monthly' ||
                selectedFrequency?.value == 'annually') {
              if (selectedFrequency != null) {
                customTreatmentText += '${selectedFrequency?.label}';
              }
              if (selectedOccasions != null) {
                customTreatmentText += ' for $selectedOccasions Occasion';
              }
            } else if (selectedFrequency?.value == 'on date') {
              if (selectedDate != null) {
                final formattedDate =
                    DateFormat('d MMMM y').format(selectedDate!);
                customTreatmentText += ' On $formattedDate';
              }
              if (selectedOccasions != null) {
                customTreatmentText += ' for $selectedOccasions Occasion';
              }
            } else {
              if (selectedNumber != null && selectedFrequency != null) {
                customTreatmentText +=
                    '${selectedFrequency?.value} $selectedNumber day${selectedNumber! > 1 ? 's' : ''}';
              }
              if (selectedOccasions != null) {
                customTreatmentText += ' for $selectedOccasions Occasion';
              }
            }

            widget.onCustomTreatmentSelected(customTreatmentText);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
