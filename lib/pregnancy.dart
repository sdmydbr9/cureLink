import 'package:flutter/material.dart';

class PregnancyDialog extends StatefulWidget {
  @override
  _PregnancyDialogState createState() => _PregnancyDialogState();
}

class _PregnancyDialogState extends State<PregnancyDialog> {
  int pregnancyMonths = 0;
  int pregnancyYears = 0;
  int pregnancyDays = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pregnancy Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: pregnancyDays,
                  onChanged: (newValue) {
                    setState(() {
                      pregnancyDays = newValue!;
                    });
                  },
                  items: List.generate(
                    31,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: 'Days',
                    hintText: 'Select days',
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: pregnancyMonths,
                  onChanged: (newValue) {
                    setState(() {
                      pregnancyMonths = newValue!;
                    });
                  },
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: 'Months',
                    hintText: 'Select months',
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: pregnancyYears,
                  onChanged: (newValue) {
                    setState(() {
                      pregnancyYears = newValue!;
                    });
                  },
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: 'Years',
                    hintText: 'Select years',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                {
                  'days': pregnancyDays,
                  'months': pregnancyMonths,
                  'years': pregnancyYears,
                },
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
