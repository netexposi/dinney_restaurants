import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';                       // 👈 for jsonDecode
import 'package:http/http.dart' as http;

final List<String> algeriaWilayas = [
  "Adrar",
  "Chlef",
  "Laghouat",
  "Oum El Bouaghi",
  "Batna",
  "Bejaia",
  "Biskra",
  "Bechar",
  "Blida",
  "Bouira",
  "Tamanrasset",
  "Tebessa",
  "Tlemcen",
  "Tiaret",
  "Tizi Ouzou",
  "Algiers",
  "Djelfa",
  "Jijel",
  "Setif",
  "Saida",
  "Skikda",
  "Sidi Bel Abbes",
  "Annaba",
  "Guelma",
  "Constantine",
  "Medea",
  "Mostaganem",
  "M'Sila",
  "Mascara",
  "Ouargla",
  "Oran",
  "El Bayadh",
  "Illizi",
  "Bordj Bou Arreridj",
  "Boumerdes",
  "El Tarf",
  "Tindouf",
  "Tissemsilt",
  "El Oued",
  "Khenchela",
  "Souk Ahras",
  "Tipaza",
  "Mila",
  "Ain Defla",
  "Naama",
  "Ain Temouchent",
  "Ghardaia",
  "Relizane",
  "Timimoun",
  "Bordj Badji Mokhtar",
  "Ouled Djellal",
  "Beni Abbes",
  "In Salah",
  "In Guezzam",
  "Touggourt",
  "Djanet",
  "El M'Ghair",
  "El Menia",
];

int? getWilayaMatricule(String wilayaName) {
  int index = algeriaWilayas.indexWhere(
    (w) => w.toLowerCase() == wilayaName.toLowerCase().trim(),
  );
  if (index != -1) {
    return index + 1; // +1 because list is 0-based
  }
  return null; // not found
}


Future<String?> getWilayaNameFromLatLng(LatLng latLng) async {
  final url = Uri.parse(
    "https://nominatim.openstreetmap.org/reverse"
    "?format=jsonv2"
    "&lat=${latLng.latitude}"
    "&lon=${latLng.longitude}"
    "&accept-language=en", // 👈 force English
  );

  final response = await http.get(url, headers: {
    "User-Agent": "YourAppName/1.0 (your@email.com)"
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["address"]["state"]; // Wilaya in English
  }
  return null;
}

/// Check if given [lat], [lng] is within 200m of user's location
bool isWithin200m(LatLng res, LatLng user) {
  // Hardcoded user location
  double userLat = user.latitude; // example: Algiers
  double userLng = user.longitude;
  double lat = res.latitude;
  double lng = res.longitude;

  // Radius of Earth in meters
  const double earthRadius = 6371000;

  double toRadians(double degree) => degree * pi / 180;

  double dLat = toRadians(lat - userLat);
  double dLng = toRadians(lng - userLng);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRadians(userLat)) *
          cos(toRadians(lat)) *
          sin(dLng / 2) *
          sin(dLng / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance <= 10000;
}

bool isWithinCity(double lat, double lng) {
  // Hardcoded user location
  const double userLat = 36.19104037159446; // example: Algiers
  const double userLng = 5.411437852797131;

  // Radius of Earth in meters
  const double earthRadius = 6371000;

  double toRadians(double degree) => degree * pi / 180;

  double dLat = toRadians(lat - userLat);
  double dLng = toRadians(lng - userLng);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRadians(userLat)) *
          cos(toRadians(lat)) *
          sin(dLng / 2) *
          sin(dLng / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance <= 20000;
}

Future<double> calculateDistance(LatLng start, LatLng end) async {
  final apiKey = 'AIzaSyCg4pGJ8ZCd8CaMNovlyOp5DOlCu8QFNOw';
  final url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['routes'].isNotEmpty) {
      // distance in meters
      final distanceMeters = data['routes'][0]['legs'][0]['distance']['value'] / 1000;
      return distanceMeters.toDouble();
    }
  }

  throw Exception('Failed to get route distance');
}