import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Future<TimeOfDay> pickTimeAppleDialog(BuildContext context, TimeOfDay initialTime) async {
  TimeOfDay tempPicked = initialTime;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
        content: SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: DateTime(
              DateTime.now().year,
              1,
              1,
              initialTime.hour,
              initialTime.minute,
            ),
            use24hFormat: true,
            onDateTimeChanged: (DateTime newTime) {
              tempPicked = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(tempPicked),
            child: const Text("Done"),
          ),
        ],
      );
    },
  );

  return tempPicked;
}
