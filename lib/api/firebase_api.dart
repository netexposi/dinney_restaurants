import 'dart:convert';
import 'dart:typed_data';

import 'package:dinney_restaurant/services/functions/graphic_operations.dart';
import 'package:dinney_restaurant/services/models/notification.dart';
import 'package:dinney_restaurant/services/models/notification_adapter.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
    'push_channel',
    'Updates Notifications',
    description: 'This channel is used for push notifications',
    importance: Importance.high,
  );

  final Ref ref; // Riverpod ref

  FirebaseApi(this.ref);

  Future<void> initLocalNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async {
        if (payload.payload != null) {
          final data = Notifications.fromJson(jsonDecode(payload.payload!));
          final box = Hive.box<Notifications>('notifications');

          final updated = data.copyWith(viewed: true);
          await box.add(updated);
          ref.read(selectedIndex.notifier).state = 2;
          AppNavigation.navRouter.go("/reservations");
        }
      },
    );

    token = await _firebaseMessaging.getToken();

    // Ensure channel exists
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> showNotification(Notifications notification) async {
    final box = Hive.box<Notifications>('notifications');
    await box.add(notification); // add to Hive immediately

    final Uint8List? imageBytes = notification.media.isNotEmpty
        ? await networkImageToUint8List(notification.media)
        : null;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: imageBytes != null ? ByteArrayAndroidBitmap(imageBytes) : null,
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  Future<void> initPushNotification() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((msg) async {
      await handleIncomingMessage(msg);
    });

    FirebaseMessaging.onMessage.listen((msg) async {
      await handleIncomingMessage(msg);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> handleIncomingMessage(RemoteMessage msg) async {
    final notification = Notifications(
      id: msg.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: msg.notification?.title ?? "No Title",
      body: msg.notification?.body ?? "No Body",
      viewed: false,
      media: msg.notification?.android?.imageUrl ?? "",
    );

    await showNotification(notification);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage msg) async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NotificationAdapter());
    }
    final box = await Hive.openBox<Notifications>('notifications');

    final notification = Notifications(
      id: msg.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: msg.notification?.title ?? "No Title",
      body: msg.notification?.body ?? "No Body",
      viewed: false,
      media: msg.notification?.android?.imageUrl ?? "",
    );

    await box.add(notification);
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    await initLocalNotification();
    await initPushNotification();
  }
}
