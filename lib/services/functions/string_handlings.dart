import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay stringToTimeOfDay(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

int getDayName(int language){
  final today = DateFormat.EEEE().format(DateTime.now()).toLowerCase();
  print("today is $today");
  int translatedDay = 0;
  if (language == 2) {
    // French to English translation
    switch (today) {
      case 'lundi':
        translatedDay = 1;
        break;
      case 'mardi':
        translatedDay = 2;
        break;
      case 'mercredi':
        translatedDay = 3;
        break;
      case 'jeudi':
        translatedDay = 4;
        break;
      case 'vendredi':
        translatedDay = 5;
        break;
      case 'samedi':
        translatedDay = 6;
        break;
      case 'dimanche':
        translatedDay = 0;
        break;
    }
  } else if (language == 1) {
    // Arabic to English translation
    switch (today) {
      case 'الاثنين':
        translatedDay = 1;
        break;
      case 'الثلاثاء':
        translatedDay = 2;
        break;
      case 'الأربعاء':
        translatedDay = 3;
        break;
      case 'الخميس':
        translatedDay = 4;
        break;
      case 'الجمعة':
        translatedDay = 5;
        break;
      case 'السبت':
        translatedDay = 6;
        break;
      case 'الأحد':
        translatedDay = 0;
        break;
    }
  }else{
    // Default to English
    switch (today) {
      case 'monday':
        translatedDay = 1;
        break;
      case 'tuesday':
        translatedDay = 2;
        break;
      case 'wednesday':
        translatedDay = 3;
        break;
      case 'thursday':
        translatedDay = 4;
        break;
      case 'friday':
        translatedDay = 5;
        break;
      case 'saturday':
        translatedDay = 6;
        break;
      case 'sunday':
        translatedDay = 0;
        break;
    }
  }
  return translatedDay;
}