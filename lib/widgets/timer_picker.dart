import 'dart:io';

import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay> pickTimeAppleDialog(
  BuildContext context,
  TimeOfDay initialTime,
) async {
  if (Platform.isIOS) {
    TimeOfDay picked = initialTime;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(S.of(context).cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(S.of(context).done),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    initialTime.hour,
                    initialTime.minute,
                  ),
                  onDateTimeChanged: (DateTime newTime) {
                    picked = TimeOfDay.fromDateTime(newTime);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    return picked;
  } else {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      helpText: S.of(context).done,
    );
    return picked ?? initialTime;
  }
}
