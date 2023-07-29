import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showMedicationNamePopup(BuildContext context, String medicationName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Medication Name'),
        content: Text('Medication Name: $medicationName'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
