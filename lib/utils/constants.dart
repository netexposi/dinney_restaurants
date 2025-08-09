import 'package:flutter_riverpod/flutter_riverpod.dart';
final signUpProvider = StateProvider<int>((ref) => 2);
final savingLoadingButton = StateProvider((ref) => false); 
final Map<String, String> tagImages = {
  "italian" : "assets/images/italian.png",
  "american" : "assets/images/american.png",
  "sugary" : "assets/images/sugary.png",
};