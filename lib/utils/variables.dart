// import 'dart:async';
// import 'dart:math';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// //FIX Change user data storing system
// late Map<String, dynamic> userDocument;
// String distanceUnit = 'Km';
// String paceUnit = 'min/Km';
// String? token;
// bool inHome = false;
// final formatter = DateFormat('dd/MM/yyyy');
// final hourlyFormatter = DateFormat('d/M/y H:m');
// final counterStateProvider = StateProvider<int>((ref) => 0);
// final languageStateProvider = StateProvider<int>((ref) => 0);
// final userDataStateProvider = StateProvider<bool>((ref) => false);
// StreamController<int> offlineRuns = StreamController.broadcast();
// StreamController<bool> uploadingRuns = StreamController.broadcast();
// Random random = Random();
// List<String> countryAlphaCodes = [
//   "DZ", "MA", "TN", "FR", "GB", "US", "RU", "ES", "IT"
// ];