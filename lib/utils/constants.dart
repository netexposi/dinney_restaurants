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
  "breakfast" : "assets/images/breakfast.jpg",
  "pizza/tacos" : "assets/images/pizzatacos.jpg",
  "american" : "assets/images/american.png",
  "plats" : "assets/images/plats.jpg",
  "sandwichs" : "assets/images/sandwichs.jpg",
  "sugary" : "assets/images/sugary.png",
  "seafood" : "assets/images/seafood.jpg",
  "vegetarian" : "assets/images/vegetarian.jpg",
  "asian" : "assets/images/asian.jpg"
};
final flagsList = ['🇬🇧', '🇩🇿', '🇫🇷'];
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');