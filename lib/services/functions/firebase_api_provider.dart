import 'package:dinney_restaurant/api/firebase_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a single instance of your Firebase API.
final firebaseApiProvider = Provider<FirebaseApi>((ref) {
  return FirebaseApi(ref);
});

/// Initializes Firebase messaging + local notifications.
final firebaseInitProvider = FutureProvider<void>((ref) async {
  final api = ref.read(firebaseApiProvider);
  await api.initNotification();
});
