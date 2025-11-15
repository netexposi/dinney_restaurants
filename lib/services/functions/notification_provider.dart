import 'package:dinney_restaurant/services/models/notification.dart';
import 'package:dinney_restaurant/services/models/notification_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider that opens and exposes the Hive notifications box.
final notificationBoxProvider = FutureProvider<Box<Notifications>>((ref) async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NotificationAdapter());
  }

  final box = await Hive.openBox<Notifications>('notifications');
  return box;
});

/// Provider that streams notification updates from Hive.
var notificationListProvider =
    StreamProvider.autoDispose<List<Notifications>>((ref) async* {
  final box = await ref.watch(notificationBoxProvider.future);
  yield box.values.toList();

  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});
