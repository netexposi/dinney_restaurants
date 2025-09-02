import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
final languageStateProvider  = StateProvider<int>((ref) => 0);
final signUpProvider = StateProvider<int>((ref) => 0);
final savingLoadingButton = StateProvider((ref) => false);
final errorProvider = StateProvider<Map<String, dynamic>>((ref) => {
  "status" : true,
  "reason" : ""
}); 
final selectedIndex = StateProvider<int>((ref) => 0);
final Map<String, String> tagImages = {
  "italian" : "assets/images/italian.png",
  "american" : "assets/images/american.png",
  "sugary" : "assets/images/sugary.png",
};
final flagsList = ['🇬🇧', '🇩🇿', '🇫🇷'];
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');