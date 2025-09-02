import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay stringToTimeOfDay(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

int getDayName(int language){
  final today = DateFormat.EEEE().format(DateTime.now());
  late int translatedDay;
  if (language == 2) {
    // French to English translation
    switch (today) {
      case 'Lundi':
        translatedDay = 1;
        break;
      case 'Mardi':
        translatedDay = 2;
        break;
      case 'Mercredi':
        translatedDay = 3;
        break;
      case 'Jeudi':
        translatedDay = 4;
        break;
      case 'Vendredi':
        translatedDay = 5;
        break;
      case 'Samedi':
        translatedDay = 6;
        break;
      case 'Dimanche':
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
      case 'Monday':
        translatedDay = 1;
        break;
      case 'Tuesday':
        translatedDay = 2;
        break;
      case 'Wednesday':
        translatedDay = 3;
        break;
      case 'Thursday':
        translatedDay = 4;
        break;
      case 'Friday':
        translatedDay = 5;
        break;
      case 'Saturday':
        translatedDay = 6;
        break;
      case 'Sunday':
        translatedDay = 0;
        break;
    }
  }
  return translatedDay;
}