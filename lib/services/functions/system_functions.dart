import 'package:hive_flutter/hive_flutter.dart';

void setLanguage(int ln) async{
  final language = await Hive.openBox('Language');
  language.add(ln);
}