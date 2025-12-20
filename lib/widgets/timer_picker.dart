import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay> pickTimeAppleDialog(
  BuildContext context,
  TimeOfDay initialTime,
) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: child!,
      );
    },
    helpText: S.of(context).done,
  );

  return picked ?? initialTime;
}
